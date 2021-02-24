@extends('layouts.settings.default')
@push('css_lib')
    <!-- iCheck -->
    <link rel="stylesheet" href="{{asset('plugins/iCheck/flat/blue.css')}}">
    <!-- select2 -->
    <link rel="stylesheet" href="{{asset('plugins/select2/select2.min.css')}}">
    <!-- bootstrap wysihtml5 - text editor -->
    <link rel="stylesheet" href="{{asset('plugins/summernote/summernote-bs4.css')}}">
    {{--dropzone--}}
    <link rel="stylesheet" href="{{asset('plugins/dropzone/bootstrap.min.css')}}">
@endpush
@section('settings_title','Mensajes Globales')
@section('settings_content')
    @include('flash::message')
    @include('adminlte-templates::common.errors')
    <div class="clearfix"></div>
    <div class="card">
        <!-- <div class="card-header">
            <ul class="nav nav-tabs align-items-end card-header-tabs w-100">
                <li class="nav-item">
                    {{-- <a class="nav-link active" href="{!! url()->current() !!}"><i class="fa fa-cog mr-2"></i>{{trans('lang.app_setting_'.$tab)}}</a> --}}
                    <a class="nav-link active" href="{!! url('settings/app/notifications') !!}"><i class="fa fa-cog mr-2"></i>{{trans('lang.app_setting_'.$tab)}}</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="{!! url('settings/app/sendMessage') !!}"><i class="fa fa-paper-plane"></i> Envíar mensaje promocional</a>
                </li>
            </ul>
        </div> -->
        <div class="card-body">
            {!! Form::open(['url' => ['settings/sendMessage'], 'method' => 'patch']) !!}
            <div class="row">

                <div class="form-group row ">
                    <label class="w-100 ml-2 form-check-inline"> Customer</label>
                    <div class="checkbox icheck">
                        <label class="col-9 ml-2 form-check-inline">
                        {!! Form::hidden('client', 0) !!}
                        {!! Form::checkbox('client', 1, null) !!}
                        </label>
                    </div>
                </div>

                <div class="form-group row ">
                    <label class="w-100 ml-2 form-check-inline"> Delivery Boys</label>
                    <div class="checkbox icheck">
                        <label class="col-9 ml-2 form-check-inline">
                        {!! Form::hidden('driver', 0) !!}
                        {!! Form::checkbox('driver', 1, null) !!}
                        </label>
                    </div>
                </div>

                <div class="form-group row ">
                    <label class="w-100 ml-2 form-check-inline"> Managers</label>
                    <div class="checkbox icheck">
                        <label class="col-9 ml-2 form-check-inline">
                        {!! Form::hidden('manager', 0) !!}
                        {!! Form::checkbox('manager', 1, null) !!}
                        </label>
                    </div>
                </div>

                <div class="form-group row ">
                    <label class="w-100 ml-2 form-check-inline"> Admins</label>
                    <div class="checkbox icheck">
                        <label class="col-9 ml-2 form-check-inline">
                        {!! Form::hidden('admin', 0) !!}
                        {!! Form::checkbox('admin', 1, null) !!}
                        </label>
                    </div>
                </div>

                <div class="form-group row ">
                    <label class="w-100 ml-2 form-check-inline"> Specific user</label>
                    <div class="checkbox icheck">
                        <label class="col-9 ml-2 form-check-inline">
                        {!! Form::hidden('specific', 0) !!}
                        {!! Form::checkbox('specific', 1, null) !!}
                        </label>
                    </div>
                </div>

                <div class="col-12">
                    <div class="form-group">
                        <label class="w-100 ml-2 form-check-inline"> Select user</label>
                        <select name="user" class="select2 form-control">
                            <?php
                            $result = DB::table('users')
                            ->select(
                                'users.id',
                                'users.name',
                                'users.email',
                                'users.device_token',
                                'model_has_roles.role_id'
                            )
                            ->leftjoin('model_has_roles', 'users.id', '=', 'model_has_roles.model_id')
                            // ->where('model_has_roles.role_id', 4)
                            ->where('users.device_token', '<>', null)
                            ->get();
                            $myArray = json_decode($result, true);

                            $album_type = '';
                            foreach ($myArray as $user){
                            if ($album_type != $user['role_id']) {
                                if ($album_type != '') {
                                echo '</optgroup>';
                                }
                                if ($user['role_id'] == 3){
                                    $rol_name = 'Manager';
                                } else if ($user['role_id'] == 4) {
                                    $rol_name = 'Cliente';
                                } else if ($user['role_id'] == 5) {
                                    $rol_name = 'Repartidor';
                                } else {
                                    $rol_name = 'Administrador';
                                }
                                echo '<optgroup label="'.ucfirst($rol_name).'">';
                            }
                            echo '<option value="'.$user['id'].'">'.$user['id'].' - '.htmlspecialchars($user['name']).' ('.$user['email'].')</option>';
                            $album_type = $user['role_id'];    
                            }
                            if ($album_type != '') {
                            echo '</optgroup>';
                            }
                            ?>
                        </select>
                    </div>
                </div>

                <div class="col-12">
                    <div class="form-group">
                        <label class="w-100 ml-2 form-check-inline"> Title</label>
                        <input type="text" name="title" class="form-control" placeholder="Ingresa un mensaje">
                    </div>
                    <div class="form-group">
                    You can use the [user] tag to refer to the user's name
                        <label class="w-100 ml-2 form-check-inline"> Message</label>
                        <textarea class="form-control" name="message"></textarea>
                    </div>
                </div>

                <!-- Submit Field -->
                <div class="form-group mt-4 col-12 text-right">
                    <button type="submit" class="btn btn-{{setting('theme_color')}}">
                        <i class="fa fa-save"></i> Send
                    </button>
                    <a href="{!! route('users.index') !!}" class="btn btn-default"><i class="fa fa-undo"></i> {{trans('lang.cancel')}}</a>
                </div>
            </div>
            {!! Form::close() !!}
            <div class="clearfix"></div>
        </div>
    </div>
    </div>
    @include('layouts.media_modal',['collection'=>null])
@endsection
@push('scripts_lib')
    <!-- iCheck -->
    <script src="{{asset('plugins/iCheck/icheck.min.js')}}"></script>
    <!-- select2 -->
    <script src="{{asset('plugins/select2/select2.min.js')}}"></script>
    <!-- AdminLTE dashboard demo (This is only for demo purposes) -->
    <script src="{{asset('plugins/summernote/summernote-bs4.min.js')}}"></script>
    {{--dropzone--}}
    <script src="{{asset('plugins/dropzone/dropzone.js')}}"></script>
    <script type="text/javascript">
        Dropzone.autoDiscover = false;
        var dropzoneFields = [];
    </script>
@endpush
