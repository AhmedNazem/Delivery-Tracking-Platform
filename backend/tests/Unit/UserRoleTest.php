<?php

namespace Tests\Unit;

use App\Enums\UserRole;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use ValueError;

class UserRoleTest extends TestCase
{
    public function test_only_blueprint_roles_are_supported(): void
    {
        $values = array_map(fn (UserRole $role): string => $role->value, UserRole::cases());

        $this->assertSame(['admin', 'dispatcher', 'driver'], $values);
    }

    public function test_stored_values_convert_to_roles(): void
    {
        $this->assertSame(UserRole::Admin, UserRole::from('admin'));
        $this->assertSame(UserRole::Dispatcher, UserRole::from('dispatcher'));
        $this->assertSame(UserRole::Driver, UserRole::from('driver'));
    }

    #[DataProvider('invalidRoleValues')]
    public function test_untrusted_values_must_match_exactly(string $value): void
    {
        $this->assertNull(UserRole::tryFrom($value));
    }

    /** @return array<string, array{string}> */
    public static function invalidRoleValues(): array
    {
        return [
            'unknown role' => ['customer'],
            'wrong case' => ['Admin'],
            'surrounding spaces' => [' driver '],
            'empty value' => [''],
        ];
    }

    public function test_strict_conversion_rejects_an_unknown_role(): void
    {
        $this->expectException(ValueError::class);

        UserRole::from('customer');
    }
}
