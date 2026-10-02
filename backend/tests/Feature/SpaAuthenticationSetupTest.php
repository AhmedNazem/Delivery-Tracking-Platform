<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class SpaAuthenticationSetupTest extends TestCase
{
    public function test_csrf_endpoint_sets_the_browser_cookies(): void
    {
        $this->withHeader('Origin', 'http://localhost:3000')
            ->get('/sanctum/csrf-cookie')
            ->assertNoContent()
            ->assertCookie('XSRF-TOKEN')
            ->assertCookie(config()->string('session.cookie'))
            ->assertHeader('Access-Control-Allow-Origin', 'http://localhost:3000')
            ->assertHeader('Access-Control-Allow-Credentials', 'true');
    }

    public function test_allowed_frontend_can_preflight_an_api_request(): void
    {
        $this->withHeaders([
            'Origin' => 'http://localhost:3000',
            'Access-Control-Request-Method' => 'POST',
            'Access-Control-Request-Headers' => 'content-type,x-xsrf-token',
        ])->options('/api/login')
            ->assertNoContent()
            ->assertHeader('Access-Control-Allow-Origin', 'http://localhost:3000')
            ->assertHeader('Access-Control-Allow-Credentials', 'true');
    }

    public function test_unknown_origin_is_not_reflected_in_cors_permission(): void
    {
        $this->withHeaders([
            'Origin' => 'https://untrusted.example',
            'Access-Control-Request-Method' => 'POST',
        ])->options('/api/login')
            ->assertHeader('Access-Control-Allow-Origin', 'http://localhost:3000');
    }

    public function test_stateful_api_requests_require_a_csrf_token(): void
    {
        // Laravel skips CSRF during tests; use the real environment branch here.
        $this->app->instance('env', 'local');
        Route::middleware('api')->post('/api/csrf-probe', fn () => response()->noContent());

        $this->withHeader('Origin', 'http://localhost:3000')
            ->postJson('/api/csrf-probe')
            ->assertStatus(419);
    }

    public function test_stateful_api_requests_accept_a_matching_csrf_token(): void
    {
        $this->app->instance('env', 'local');
        Route::middleware('api')->post('/api/csrf-probe', fn () => response()->noContent());

        $this->withSession(['_token' => 'test-csrf-token'])
            ->withHeaders([
                'Origin' => 'http://localhost:3000',
                'X-CSRF-TOKEN' => 'test-csrf-token',
            ])->postJson('/api/csrf-probe')
            ->assertNoContent();
    }
}
