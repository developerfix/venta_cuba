<?php
// CORRECTED addListing function

public function addListing(Request $request)
{
    $validator = Validator::make($request->all(), [
        'category_id' => 'required|exists:categories,id,deleted_at,NULL',
        'sub_category_id' => 'nullable|exists:sub_categories,id,deleted_at,NULL',
        'sub_sub_category_id' => 'nullable|exists:sub_sub_categories,id,deleted_at,NULL',
        'title' => 'required',
        'currency' => 'required',
        'price' => 'required|numeric',
        'description' => 'required',
        'address' => 'required',
        'latitude' => 'required',
        'longitude' => 'required',
        'additional_features' => 'required',
        'tag' => 'nullable',
        'business_status' => 'required|boolean',
    ]);
    
    if ($validator->fails()) {
        return response()->json($validator->errors(), SiteHelper::$bad_request_status);
    }
    
    // Check user package
    $settings = Setting::find(1);
    $countListing = Listing::where('user_id', $request->user()->id)->withTrashed()->count();
    $subscription = Model_Subscription::where('user_id', $request->user()->id)->first();
    
    if ($countListing >= $settings->free_listings_limit) {
        if (!empty($subscription)) {
            if ($countListing >= $settings->free_listings_limit) {
                if ($subscription->status == 'pending') {
                    $data = array(
                        'status' => false,
                        'message' => 'Your package is in pending, waiting for admin approval.'
                    );
                    return response()->json($data, SiteHelper::$success_status);
                } elseif ($subscription->status == 'rejected') {
                    $data = array(
                        'status' => false,
                        'message' => 'Your package is being rejected by admin and free limit is completed. For more listing, you can purchase new package.'
                    );
                    return response()->json($data, SiteHelper::$success_status);
                } elseif ($subscription->status == 'expired') {
                    $data = array(
                        'status' => false,
                        'message' => 'Your package is expired and free limit is completed. For more listing, you can purchase new package.'
                    );
                    return response()->json($data, SiteHelper::$success_status);
                }
            }
        } else {
            if ($countListing >= 1000) {
                $data = array(
                    'status' => false,
                    'message' => 'Your free limit is completed. For more listing, you can purchase package.'
                );
                return response()->json($data, SiteHelper::$success_status);
            }
        }
    }
    
    // Images - CORRECTED CODE
    $Images = array();
    if ($request->hasFile('gallery')) {  // FIXED: Use hasFile() for file uploads
        foreach ($request->file('gallery') as $index => $image) {  // FIXED: Use file() to get uploaded files
            $FileName = 'ListingImage-' . mt_rand(100000, 999999) . '-' . time() . '-' . $index . '.' . $image->extension();
            $image->storeAs('public/listing', $FileName);
            $Images[] = $FileName;
        }
    }

    // Add record in database
    DB::beginTransaction();
    $Affected = null;
    $Affected = Listing::create([
        'user_id' => $request->user()->id,
        'category_id' => $request['category_id'],
        'sub_category_id' => $request['sub_category_id'],
        'sub_sub_category_id' => $request['sub_sub_category_id'],
        'title' => $request['title'],
        'gallery' => count($Images) > 0 ? json_encode($Images) : null,
        'price' => $request['price'],
        'description' => $request['description'],
        'currency' => $request['currency'],
        'address' => $request['address'],
        'latitude' => $request['latitude'],
        'longitude' => $request['longitude'],
        'tag' => $request['tag'],
        'additional_features' => $request['additional_features'],
        'business_status' => $request['business_status'],
        'created_at' => Carbon::now()
    ]);
    
    // Notification code remains the same...
    $fav_array = array();
    $fav = FavouriteSeller::where('seller_id', $request->user()->id)->get();
    foreach ($fav as $value) {
        $users = User::where('id', $value->user_id)->where('deleted_at', null)->get();
        foreach ($users as $user) {
            if ($user->all_notifications == 1) {
                $sub_array = array();
                $sub_array['user_id'] = $value->user_id;
                $sub_array['seller_id'] = $request->user()->id;
                $sub_array['listing_id'] = $Affected->id;
                $sub_array['message'] = 'New listing posted by' . ' ' . $request->user()->first_name . ' ' . $request->user()->last_name;
                $sub_array['read_status'] = 0;
                $sub_array['created_at'] = Carbon::now();
                $sub_array['updated_at'] = Carbon::now();
                $fav_array[] = $sub_array;
                
                // FCM Notification (keeping existing code)
                // ... FCM code remains the same ...
                break;
            }
        }
    }
    
    foreach (array_chunk($fav_array, 1000) as $data) {
        DB::table('notifications')->insert($data);
    }
    
    $listings = Listing::with('user', 'category', 'SubCategory', 'SubSubCategory')
        ->where('id', $Affected->id)
        ->where('user_id', $request->user()->id)
        ->first();
        
    $listings->makeHidden(['created_at', 'deleted_at']);
    $listings->user->makeHidden(['email_verified_at', 'package_id', 'start_date', 'end_date', 'role', 'status', 'created_at', 'updated_at', 'deleted_at']);
    $listings->category->makeHidden(['created_at', 'updated_at', 'deleted_at']);
    
    if (!empty($request['sub_category_id'])) {
        $listings->SubCategory->makeHidden(['created_at', 'updated_at', 'deleted_at']);
    }
    if (!empty($request['sub_sub_category_id'])) {
        $listings->SubSubCategory->makeHidden(['created_at', 'updated_at', 'deleted_at']);
    }
    
    if ($Affected) {
        DB::commit();
        $data = array(
            'status' => true,
            'message' => 'Listing save successfully',
            'data' => $listings,
        );
        return response()->json($data, SiteHelper::$success_status);
    } else {
        DB::rollBack();
        $data = array(
            'status' => false,
            'message' => 'An unhandled error exception'
        );
        return response()->json($data, SiteHelper::$error_status);
    }
}
