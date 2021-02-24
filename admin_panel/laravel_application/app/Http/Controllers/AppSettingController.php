<?php
/**
 * File name: AppSettingController.php
 * Last modified: 2020.06.11 at 12:54:51
 * Author: SmarterVision - https://codecanyon.net/user/smartervision
 * Copyright (c) 2020
 */

namespace App\Http\Controllers;

use App\Repositories\CurrencyRepository;
use App\Repositories\RoleRepository;
use App\Repositories\UploadRepository;
use App\Repositories\UserRepository;
use Flash;
use Illuminate\Filesystem\Filesystem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Str;
use RachidLaasri\LaravelInstaller\Helpers\MigrationsHelper;
use Themsaid\Langman\Manager;
use Illuminate\Support\Facades\DB;

class AppSettingController extends Controller
{
    use MigrationsHelper;
    /** @var  UserRepository */
    private $userRepository;

    /**
     * @var RoleRepository
     */
    private $roleRepository;

    private $langManager;
    private $uploadRepository;
    private $currencyRepository;

    public function __construct(UserRepository $userRepo, RoleRepository $roleRepo, UploadRepository $uploadRepository, CurrencyRepository $currencyRepository)
    {
        parent::__construct();
        $this->userRepository = $userRepo;
        $this->roleRepository = $roleRepo;
        $this->currencyRepository = $currencyRepository;
        $this->langManager = new Manager(new Filesystem(), config('langman.path'), []);
        $this->uploadRepository = $uploadRepository;
    }

    public function update(Request $request)
    {
        if(!env('APP_DEMO',false)){ 
            $input = $request->except(['_method', '_token']);
            if (Str::endsWith(url()->previous(), "app/globals")) {
                if (empty($input['app_logo'])) {
                    unset($input['app_logo']);
                }
                if (empty($input['custom_field_models'])) {
                    setting()->forget('custom_field_models');
                }
                if (!isset($input['blocked_ips'])) {
                    unset($input['blocked_ips']);
                    setting()->forget('blocked_ips');
                }
            } else if (Str::contains(url()->previous(), "payment")) {
                if (isset($input['default_currency'])) {
                    $currency = $this->currencyRepository->findWithoutFail($input['default_currency']);
                    if (!empty($currency)) {
                        $input['default_currency_id'] = $input['default_currency'];
                        $input['default_currency'] = $currency->symbol;
                        $input['default_currency_code'] = $currency->code;
                        $input['default_currency_decimal_digits'] = $currency->decimal_digits;
                        $input['default_currency_rounding'] = $currency->rounding;
                    }
                }
//                if(isset($input['enable_stripe']) && $input['enable_stripe'] == 1){
//                    $input['enable_razorpay'] = 0;
//                }
//                if(isset($input['enable_razorpay']) && $input['enable_razorpay'] == 1){
//                    $input['enable_stripe'] = 0;
//                }
            }
            if (empty($input['mail_password'])) {
                unset($input['mail_password']);
            }
            $input = array_map(function ($value) { return is_null($value)? false : $value; }, $input);

            setting($input)->save();
            Flash::success(trans('lang.app_setting_global').' updated successfully.');
            Artisan::call("config:clear");
        }else{
            Flash::warning('This is only demo app you can\'t change this section ');
        }

        return redirect()->back();
    }

    public function message(Request $request)
    {
        if(!env('APP_DEMO',false)){
            define('API_ACCESS_KEY', setting('fcm_key'));

            $user = $request['user'];
            $title = $request['title'];
            $message = $request['message'];
            
            if ($request['client'] == 1){
                $this->sendFCMMultiple(4, $title, $message);
                // return 'client';
            } else if ($request['driver'] == 1){
                $this->sendFCMMultiple(5, $title, $message);
                // return 'driver';
            } else if ($request['manager'] == 1){
                $this->sendFCMMultiple(3, $title, $message);
                // return 'manager';
            } else if ($request['admin'] == 1){
                $this->sendFCMMultiple(2, $title, $message);
                // return 'manager';
            } else if ($request['specific'] == 1){
                $this->sendFCMSingle($user, $title, $message);
                //$this->sendFCMMultiple(3, $title, $message);
                // return 'manager';
            } else {
                Flash::warning('Parece que hubo un problema');
            }

            Flash::success(trans('lang.app_setting_global').' updated successfully.');
            Artisan::call("config:clear");
        }else{
            Flash::warning('This is only demo app you can\'t change this section ');
        }
        return redirect()->back();
    }

    //Metodo para un multiples device_token
    private function sendFCMMultiple($rol, $title_request, $message_request){
        $rol_message = $rol;
        $result = DB::table('users')
        ->select(
            'users.device_token'
        )
        ->leftjoin('model_has_roles', 'users.id', '=', 'model_has_roles.model_id')
        ->where('model_has_roles.role_id', $rol_message)
        ->where('users.device_token', '<>', null)
        ->get();
        $myArray = json_decode($result, true);

        foreach ($myArray as $user){

            $title = $title_request;
            $message = strip_tags($message_request);
            $registrationIds = $user['device_token'];
            #prep the bundle
            $msg = array(
                'body'  => $message,
                'title' => $title,
                'sound' => 'default',
                'vibrate' => '1',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                'color' => setting('main_color'),
                'id' => '1',
                'status' => 'done',
                // 'icon'=>'https://www.example.com/images/icon.png'
            );
            $fields = array(
                'to' => $registrationIds,
                'notification' => $msg,
                'priority' => 'high'
            );
            $headers = array(
                'Authorization: key=' . API_ACCESS_KEY,
                'Content-Type: application/json'
            );
            #Send Reponse To FireBase Server
            $ch = curl_init();
            curl_setopt( $ch,CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send');
            curl_setopt( $ch,CURLOPT_POST, true );
            curl_setopt( $ch,CURLOPT_HTTPHEADER, $headers );
            curl_setopt( $ch,CURLOPT_RETURNTRANSFER, true );
            curl_setopt( $ch,CURLOPT_SSL_VERIFYPEER, false );
            curl_setopt( $ch,CURLOPT_POSTFIELDS, json_encode( $fields ) );

            $result = curl_exec ( $ch );
            // echo "<pre>";print_r($result);exit;
            curl_close ( $ch );
        }
    }

    //Metodo para un solo device_token
    private function sendFCMSingle($user, $title_request, $message_request){
        $fcmUrl = 'https://fcm.googleapis.com/fcm/send';
        $user_id = $user;
        $user_token = $this->userRepository->findByField('id', $user_id)->first();

        $resultadoMensaje = str_replace("[user]", $user_token['name'], strip_tags($message_request));

        $notification = [
            'title' => $title_request,
            'body' => $resultadoMensaje,
            'sound' => 'default',
            'vibrate' => '1',
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            'color' => setting('main_color'),
            'id' => '1',
            'status' => 'done'
        ];
        $extraNotificationData = ["message" => $notification,"moredata" =>'dd'];

        $fcmNotification = [
            'to' => $user_token['device_token'], //single token
            'notification' => $notification,
            'priority' => 'high',
            //'data' => $extraNotificationData
        ];

        $headers = [
            'Authorization: key=' . API_ACCESS_KEY,
            'Content-Type: application/json'
        ];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $fcmUrl);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fcmNotification));
        $result = curl_exec($ch);
        curl_close($ch);
    }

    public function syncTranslation(Request $request)
    {
        if(!env('APP_DEMO',false)) {
            Artisan::call('langman:sync');
        }else{
            Flash::warning('This is only demo app you can\'t change this section ');
        }
        return redirect()->back();
    }

    public function checkForUpdates(Request $request)
    {
        if (!env('APP_DEMO', false)) {
            Artisan::call('config:clear');
            Artisan::call('cache:clear');
            Artisan::call('cache:forget', ['key' => 'spatie.permission.cache']);
            Artisan::call('view:clear');
            Artisan::call('route:clear');
            $executedMigrations = $this->getExecutedMigrations();
            $newMigrations = $this->getMigrations(config('installer.currentVersion', 'v100'));

            $containsUpdate = !empty($newMigrations) && count(array_intersect($newMigrations, $executedMigrations->toArray())) == count($newMigrations);
            if (!$containsUpdate) {
                return redirect(url('update/' . config('installer.currentVersion', 'v100')));
            }
        }
        Flash::warning(__('lang.app_setting_already_updated'));
        return redirect()->back();

    }

    public function clearCache(Request $request)
    {
        if (!env('APP_DEMO', false)) {
            Artisan::call('cache:forget', ['key' => 'spatie.permission.cache']);
            Artisan::call('cache:clear');
            Artisan::call('config:clear');
            Artisan::call('view:clear');
            Artisan::call('route:clear');
            Flash::success(__('lang.app_setting_cache_is_cleared'));
        } else {
            Flash::warning('This is only demo app you can\'t change this section ');
        }
        return redirect()->back();
    }

    public function translate(Request $request)
    {
        //translate only lang.php file

        if(!env('APP_DEMO',false)) {
            $inputs = $request->except(['_method', '_token', '_current_lang']);
            $currentLang = $request->input('_current_lang');
            if (!$inputs && !count($inputs)) {
                Flash::error('Translate not loaded');
                return redirect()->back();
            }
            $langFiles = $this->langManager->files();
            $langFiles = array_filter($langFiles, function($v, $k) {
                return $k == 'lang';
            }, ARRAY_FILTER_USE_BOTH);

            if (!$langFiles && !count($langFiles)) {
                Flash::error('Translate not loaded');
                return redirect()->back();
            }
            foreach ($langFiles as $filename => $items) {
                $path = $items[$currentLang];
                $needed = [];
                foreach ($inputs as $key => $input) {
                    if (starts_with($key, $filename)) {
                        $langKeyWithoutFile = explode('|',$key,2)[1];
                        $needed = array_merge_recursive($needed , getNeededArray('|',$langKeyWithoutFile,$input));
                    }
                }
                ksort($needed);
                $this->langManager->writeFile($path, $needed);
            }
        }else{
            Flash::warning('This is only demo app you can\'t change this section ');
        }

        return redirect()->back();
    }


    public function index($type = null, $tab = null)
    {
        if (empty($type)) {
            Flash::error(trans('lang.app_setting_global').'not found');
            return redirect()->back();
        }
        $executedMigrations = $this->getExecutedMigrations();
        $newMigrations = $this->getMigrations(config('installer.currentVersion', 'v100'));
        $containsUpdate = !empty($newMigrations) && count(array_intersect($newMigrations, $executedMigrations->toArray())) != count($newMigrations);

        $langFiles = [];
        $languages = getAvailableLanguages();
        $mobileLanguages = getLanguages();
        if ($type && $type === 'translation' && $tab) {
            if (!array_has($languages, $tab)) {
                Flash::error('Translate not loaded');
                return redirect()->back();
            }
            $langFiles = $this->langManager->files();
            return view('settings.' . $type . '.index', compact(['languages', 'type', 'tab', 'langFiles']));

        }

        foreach (timezone_abbreviations_list() as $abbr => $timezone) {
            foreach ($timezone as $val) {
                if (isset($val['timezone_id'])) {
                    $group = preg_split('/\//', $val['timezone_id'])[0];
                    $timezones[$group][$val['timezone_id']] = $val['timezone_id'];
                }
            }
        }
        $upload = $this->uploadRepository->findByField('uuid', setting('app_logo'))->first();

        $currencies = $this->currencyRepository->all()->pluck('name_symbol', 'id');

        $customFieldModels = getModelsClasses(app_path('Models'));

        return view('settings.' . $type . '.' . $tab . '', compact(['languages', 'type', 'tab', 'langFiles', 'timezones', 'upload', 'customFieldModels', 'currencies', 'mobileLanguages', 'containsUpdate']));
    }

    public function initFirebase()
    {
        return response()->view('vendor.notifications.sw_firebase')->header('Content-Type', 'application/javascript');
    }


}
