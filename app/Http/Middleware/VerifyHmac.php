<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class VerifyHmac
{
    public function handle(Request $request, Closure $next)
    {
        $user = auth()->user();

        if (! $user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        $timestamp = $request->header('X-TIMESTAMP');
        $signature = $request->header('X-SIGNATURE');

        if (! $timestamp || ! $signature) {
            return response()->json([
                'message' => 'Invalid headers',
            ], 401);
        }

        // Maksimal request 5 menit
        if (abs(time() - (int) $timestamp) > 300) {
            return response()->json([
                'message' => 'Request expired',
            ], 401);
        }

        $body = $request->getContent();

        $payload = $timestamp.$body;

        $generatedSignature = hash_hmac(
            'sha256',
            $payload,
            $user->hmac_key
        );

        if (! hash_equals($generatedSignature, $signature)) {
            return response()->json([
                'message' => 'Invalid signature',
            ], 401);
        }

        return $next($request);
    }
}
