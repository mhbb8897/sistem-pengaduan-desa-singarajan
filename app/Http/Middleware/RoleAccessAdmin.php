<?php

namespace App\Http\Middleware;

use Closure;

class RoleAccessAdmin
{
    public function handle($request, Closure $next)
    {
        if (auth()->check() && auth()->user()->hasRole('super_admin')) {
            // auth()->logout(); // Auto logout

            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak: Super Admin tidak diizinkan.',
            ], 403);
        }

        return $next($request);
    }
}
