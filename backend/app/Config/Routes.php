<?php

namespace Config;

use CodeIgniter\Router\RouteCollection;
use Config\Services;

/**
 * @var RouteCollection $routes
 */
$routes = Services::routes();

// ------------------------------------------------------------
// Router Setup
// ------------------------------------------------------------
$routes->setDefaultNamespace('App\Controllers');
$routes->setDefaultController('LoginController');
$routes->setDefaultMethod('index');
$routes->setTranslateURIDashes(false);
$routes->set404Override();

// Auto Routing OFF (recommended)
$routes->setAutoRoute(false);

// ------------------------------------------------------------
// Routes
// ------------------------------------------------------------

// Health
$routes->get('/', 'LoginController::index');

// CSRF + auth state
$routes->get('api/csrf', 'LoginController::csrf');
$routes->get('api/me', 'LoginController::me');

// API
$routes->group('api', static function (RouteCollection $routes) {
    $routes->post('login', 'LoginController::login');
    $routes->post('logout', 'LoginController::logout');

    $routes->get('menu', 'LoginController::menuTree', ['filter' => 'auth']);
    $routes->post('menu', 'LoginController::createMenuItem', ['filter' => 'auth']);
});