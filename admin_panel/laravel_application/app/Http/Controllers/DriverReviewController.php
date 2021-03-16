<?php
/**
 * File name: RestaurantReviewController.php
 * Last modified: 2020.05.04 at 09:04:19
 * Author: SmarterVision - https://codecanyon.net/user/smartervision
 * Copyright (c) 2020
 *
 */

namespace App\Http\Controllers;

use App\Criteria\DriverReviews\DriverReviewsOfUserCriteria;
use App\DataTables\DriverReviewDataTable;
use App\Http\Requests\CreateDriverReviewRequest;
use App\Http\Requests\UpdateDriverReviewRequest;
use App\Repositories\CustomFieldRepository;
use App\Repositories\DriverReviewRepository;
use App\Repositories\DriverRepository;
use App\Repositories\UserRepository;
use Flash;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Response;
use Prettus\Validator\Exceptions\ValidatorException;

class DriverReviewController extends Controller
{
    /** @var  driverReviewRepository */
    private $driverReviewRepository;

    /**
     * @var CustomFieldRepository
     */
    private $customFieldRepository;

    /**
     * @var UserRepository
     */
    private $userRepository;

    public function __construct(DriverReviewRepository $driverReviewRepo, CustomFieldRepository $customFieldRepo, UserRepository $userRepo
        )
    {
        parent::__construct();
        $this->driverReviewRepository = $driverReviewRepo;
        $this->customFieldRepository = $customFieldRepo;
        $this->userRepository = $userRepo;
    }

    /**
     * Display a listing of the RestaurantReview.
     *
     * @param RestaurantReviewDataTable $restaurantReviewDataTable
     * @return Response
     */
    public function index(DriverReviewDataTable $driverReviewDataTable)
    {
        return $driverReviewDataTable->render('driver_reviews.index');
    }

    /**
     * Show the form for creating a new RestaurantReview.
     *
     * @return Response
     */
    public function create()
    {
        $user = $this->userRepository->pluck('name', 'id');
        $restaurant = $this->restaurantRepository->pluck('name', 'id');

        $hasCustomField = in_array($this->driverReviewRepository->model(), setting('custom_field_models', []));
        if ($hasCustomField) {
            $customFields = $this->customFieldRepository->findByField('custom_field_model', $this->driverReviewRepository->model());
            $html = generateCustomField($customFields);
        }
        return view('restaurant_reviews.create')->with("customFields", isset($html) ? $html : false)->with("user", $user)->with("restaurant", $restaurant);
    }

    /**
     * Store a newly created RestaurantReview in storage.
     *
     * @param CreateRestaurantReviewRequest $request
     *
     * @return Response
     */
    public function store(CreateRestaurantReviewRequest $request)
    {
        $input = $request->all();
        $customFields = $this->customFieldRepository->findByField('custom_field_model', $this->driverReviewRepository->model());
        try {
            $restaurantReview = $this->driverReviewRepository->create($input);
            $restaurantReview->customFieldsValues()->createMany(getCustomFieldsValues($customFields, $request));

        } catch (ValidatorException $e) {
            Flash::error($e->getMessage());
        }

        Flash::success(__('lang.saved_successfully', ['operator' => __('lang.restaurant_review')]));

        return redirect(route('restaurantReviews.index'));
    }

    /**
     * Display the specified RestaurantReview.
     *
     * @param int $id
     *
     * @return Response
     */
    public function show($id)
    {
        $restaurantReview = $this->driverReviewRepository->findWithoutFail($id);

        if (empty($restaurantReview)) {
            Flash::error('Restaurant Review not found');

            return redirect(route('restaurantReviews.index'));
        }

        return view('restaurant_reviews.show')->with('restaurantReview', $restaurantReview);
    }

    /**
     * Show the form for editing the specified RestaurantReview.
     *
     * @param int $id
     *
     * @return Response
     * @throws \Prettus\Repository\Exceptions\RepositoryException
     */
    public function edit($id)
    {
        $this->driverReviewRepository->pushCriteria(new DriverReviewsOfUserCriteria(auth()->id()));
        $driverReview = $this->driverReviewRepository->findWithoutFail($id);
        if (empty($driverReview)) {
            Flash::error(__('lang.not_found', ['operator' => __('lang.driver_review')]));

            return redirect(route('driverReviews.index'));
        }
        $user = $this->userRepository->pluck('name', 'id');

        $customFieldsValues = $driverReview->customFieldsValues()->with('customField')->get();
        $customFields = $this->customFieldRepository->findByField('custom_field_model', $this->driverReviewRepository->model());
        $hasCustomField = in_array($this->driverReviewRepository->model(), setting('custom_field_models', []));
        if ($hasCustomField) {
            $html = generateCustomField($customFields, $customFieldsValues);
        }

        return view('driver_reviews.edit')->with('driverReview', $driverReview)->with("customFields", isset($html) ? $html : false)->with("user", $user);
    }

    /**
     * Update the specified RestaurantReview in storage.
     *
     * @param int $id
     * @param UpdateRestaurantReviewRequest $request
     *
     * @return Response
     * @throws \Prettus\Repository\Exceptions\RepositoryException
     */
    public function update($id, UpdateDriverReviewRequest $request)
    {
        $this->driverReviewRepository->pushCriteria(new DriverReviewsOfUserCriteria(auth()->id()));
        $driverReviews = $this->driverReviewRepository->findWithoutFail($id);

        if (empty($driverReviews)) {
            Flash::error('Driver Review not found');
            return redirect(route('driverReviews.index'));
        }
        $input = $request->all();
        $customFields = $this->customFieldRepository->findByField('custom_field_model', $this->driverReviewRepository->model());
        try {
            $driverReview = $this->driverReviewRepository->update($input, $id);


            foreach (getCustomFieldsValues($customFields, $request) as $value) {
                $driverReview->customFieldsValues()
                    ->updateOrCreate(['custom_field_id' => $value['custom_field_id']], $value);
            }
        } catch (ValidatorException $e) {
            Flash::error($e->getMessage());
        }

        Flash::success(__('lang.updated_successfully', ['operator' => __('lang.driver_review')]));

        return redirect(route('driverReviews.index'));
    }

    /**
     * Remove the specified RestaurantReview from storage.
     *
     * @param int $id
     *
     * @return Response
     * @throws \Prettus\Repository\Exceptions\RepositoryException
     */
    public function destroy($id)
    {
        $this->driverReviewRepository->pushCriteria(new RestaurantReviewsOfUserCriteria(auth()->id()));
        $restaurantReview = $this->driverReviewRepository->findWithoutFail($id);

        if (empty($restaurantReview)) {
            Flash::error('Restaurant Review not found');

            return redirect(route('restaurantReviews.index'));
        }

        $this->driverReviewRepository->delete($id);

        Flash::success(__('lang.deleted_successfully', ['operator' => __('lang.restaurant_review')]));

        return redirect(route('restaurantReviews.index'));
    }

    /**
     * Remove Media of RestaurantReview
     * @param Request $request
     */
    public function removeMedia(Request $request)
    {
        $input = $request->all();
        $restaurantReview = $this->driverReviewRepository->findWithoutFail($input['id']);
        try {
            if ($restaurantReview->hasMedia($input['collection'])) {
                $restaurantReview->getFirstMedia($input['collection'])->delete();
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
        }
    }
}
