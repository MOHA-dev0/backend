<x-filament::page>
    <div class="overflow-x-auto relative shadow-md sm:rounded-lg border border-gray-200 dark:border-gray-700">
        <table class="w-full text-sm text-right text-gray-500 dark:text-gray-400">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
                <tr>
                    <th scope="col" class="py-3 px-6">
                        رمز التحقق (OTP)
                    </th>
                    <th scope="col" class="py-3 px-6">
                        رقم الهاتف
                    </th>
                    <th scope="col" class="py-3 px-6">
                        تاريخ الإرسال
                    </th>
                </tr>
            </thead>
            <tbody>
                @forelse($logs as $log)
                    <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
                        <td class="py-4 px-6 font-bold text-primary-600 dark:text-primary-500 text-lg">
                            <span class="cursor-pointer" onclick="navigator.clipboard.writeText('{{ $log['code'] }}'); alert('تم نسخ الرمز')">
                                {{ $log['code'] }} 
                                <x-heroicon-o-clipboard-document class="w-4 h-4 inline ml-1 opacity-50 hover:opacity-100"/>
                            </span>
                        </td>
                        <td class="py-4 px-6 font-medium text-gray-900 dark:text-white whitespace-nowrap">
                            <span dir="ltr">{{ $log['phone'] }}</span>
                        </td>
                        <td class="py-4 px-6">
                            {{ $log['date'] }}
                        </td>
                    </tr>
                @empty
                    <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
                        <td colspan="3" class="py-6 px-6 text-center text-gray-500">
                            لا توجد سجلات OTP محفوظة في ملف السجل حالياً.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</x-filament::page>
