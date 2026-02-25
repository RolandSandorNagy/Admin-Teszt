<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

/**
 * NOTE:
 * This file is meant to be COPY-PASTED into a real CodeIgniter 4 project created by Composer.
 * See README.md for setup steps.
 */
$routes = Services::routes();

$routes->setDefaultNamespace('App\Controllers');
$routes->setDefaultController('LoginController');
$routes->setDefaultMethod('index');
$routes->setTranslateURIDashes(false);
$routes->set404Override();

// If you use CI4's Auto Routing, keep it OFF for this task (recommended).
$routes->setAutoRoute(false);

$routes->get('api/me', 'LoginController::me');
$routes->get('api/csrf', 'LoginController::csrf');

// Health / fallback
$routes->get('/', 'LoginController::index');

// API
$routes->group('api', static function($routes) {
    $routes->post('login', 'LoginController::login');
    $routes->post('logout', 'LoginController::logout');

    $routes->get('menu', 'LoginController::menuTree', ['filter' => 'auth']);
    $routes->post('menu', 'LoginController::createMenuItem', ['filter' => 'auth']);
});
