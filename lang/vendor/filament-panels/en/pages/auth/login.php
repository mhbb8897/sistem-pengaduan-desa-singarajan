<?php

return [

    'title' => 'Login',

    'heading' => 'Login Administrator',

    'actions' => [

        'register' => [
            'before' => 'or',
            'label' => 'sign up for an account',
        ],

        'request_password_reset' => [
            'label' => 'Lupa Password?',
        ],

    ],

    'form' => [

        'email' => [
            'label' => 'Email address',
        ],

        'password' => [
            'label' => 'Password',
        ],

        'remember' => [
            'label' => 'Ingat Saya',
        ],

        'actions' => [

            'authenticate' => [
                'label' => 'Masuk',
            ],

        ],

    ],

    'messages' => [

        'failed' => 'Akun tidak ada, mohon hubungi administrator desa.',

    ],

    'notifications' => [

        'throttled' => [
            'title' => 'Too many login attempts',
            'body' => 'Please try again in :seconds seconds.',
        ],

    ],

];
