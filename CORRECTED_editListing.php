<?php
// CORRECTED editListing function

public function editListing(Request $request)
{
    $validator = Validator::make($request->all(), [
        'listing_id' => 'required|exists:listings,id,deleted_at,NULL',
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
    ]);
    
    if ($validator->fails()) {
        return response()->json($validator->errors(), SiteHelper::$bad_request_status);
    }
    
    $listing = Listing::where('id', $request->listing_id)->where('user_id', $request->user()->id)->first();
    if (empty($listing)) {
        $data = array(
            'status' => false,
            'message' => 'Invalid listing id'
        );
        return response()->json($data, SiteHelper::$bad_request_status);
    }
    
    // Images - CORRECTED CODE
    if ($request->hasFile('gallery')) {  // FIXED: Use hasFile() for file uploads
        // Delete old images if they exist
        if ($listing->gallery != null) {
            $oldImages = json_decode($listing->gallery);  // FIXED: Decode JSON first
            if (is_array($oldImages)) {
                foreach ($oldImages as $index => $imageName) {
                    $files = public_path('storage/listing') . '/' . $imageName;
                    if (file_exists($files)) {
                        unlink($files);
                    }
                }
            }
        }
        
        // Upload new images
        $Images = array();
        foreach ($request->file('gallery') as $index => $image) {  // FIXED: Use file() to get uploaded files
            $FileName = 'ListingImage-' . mt_rand(100000, 999999) . '-' . time() . '-' . $index . '.' . $image->extension();
            $image->storeAs('public/listing', $FileName);
            $Images[] = $FileName;
        }
    }
    
    // Update record in database
    DB::beginTransaction();
    $listing->user_id = $request->user()->id;
    $listing->category_id = $request['category_id'];
    $listing->sub_category_id = $request['sub_category_id'];
    $listing->sub_sub_category_id = $request['sub_sub_category_id'];
    $listing->title = $request['title'];
    
    // Only update gallery if new images were uploaded
    if (!empty($Images)) {
        $listing->gallery = json_encode($Images);
    }
    
    $listing->price = $request['price'];
    $listing->description = $request['description'];
    $listing->currency = $request['currency'];
    $listing->address = $request['address'];
    $listing->latitude = $request['latitude'];
    $listing->longitude = $request['longitude'];
    $listing->tag = $request['tag'];
    $listing->additional_features = $request['additional_features'];
    $listing->updated_at = Carbon::now();
    $listing->save();

    $Affected = Listing::with('user', 'category', 'SubCategory', 'SubSubCategory')
        ->where('id', $listing->id)
        ->where('user_id', $request->user()->id)
        ->first();
        
    $Affected->makeHidden(['created_at', 'deleted_at']);
    $Affected->user->makeHidden(['email_verified_at', 'package_id', 'start_date', 'end_date', 'role', 'status', 'created_at', 'updated_at', 'deleted_at']);
    $Affected->category->makeHidden(['created_at', 'updated_at', 'deleted_at']);
    
    if (!empty($request['sub_category_id'])) {
        $Affected->SubCategory->makeHidden(['created_at', 'updated_at', 'deleted_at']);
    }
    if (!empty($request['sub_sub_category_id'])) {
        $Affected->SubSubCategory->makeHidden(['created_at', 'updated_at', 'deleted_at']);
    }
    
    if ($Affected) {
        DB::commit();
        $data = array(
            'status' => true,
            'message' => 'Listing updated successfully',
            'data' => $Affected,
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
