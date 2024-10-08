include windows.inc
include kernel32.inc
include user32.inc
include masm32.inc

.data
    promptNumRecords db "Number of Records: ", 0
    promptRecordYear db "%d Record Year: ", 0
    promptAlbumName db "%d Album Name: ", 0
    promptArtistName db "%d Artist Name: ", 0
    promptFetchYear db "Enter the year to fetch records: ", 0
    resultFormat db "%d - %d - %s - %s", 0

    numRecords dd ?
    fetchYear dd ?
    count dd ?
    recordPositions dd ?
    filteredRecords dd ?
    
    records RECORD 100 dup (?, 32 dup (0), 32 dup (0))

.code
start:
    invoke StdOut, addr promptNumRecords
    invoke StdIn, addr numRecords, sizeof numRecords
    mov ecx, [numRecords]

    invoke HeapAlloc, GetProcessHeap(), HEAP_ZERO_MEMORY, ecx * sizeof RECORD
    mov [records], eax

    mov esi, [records]
    mov edi, 0
read_records:
    invoke StdOut, addr promptRecordYear
    invoke StdIn, addr [esi + edi*sizeof RECORD], sizeof dd
    invoke StdOut, addr promptAlbumName
    invoke StdIn, addr [esi + edi*sizeof RECORD + 4], 32
    invoke StdOut, addr promptArtistName
    invoke StdIn, addr [esi + edi*sizeof RECORD + 36], 32
    inc edi
    loop read_records

    invoke StdOut, addr promptFetchYear
    invoke StdIn, addr fetchYear, sizeof fetchYear

    invoke fetchRecords, [records], [numRecords], [fetchYear], addr count, addr recordPositions
    mov edx, [count]


    mov ebx, [recordPositions]
    mov esi, [filteredRecords]
print_records:
    invoke wsprintf, addr resultFormat, ebx, [esi + 4], addr [esi + 8], addr [esi + 40]
    invoke StdOut, addr resultFormat
    add ebx, sizeof dd
    add esi, sizeof RECORD
    dec edx
    jnz print_records


    invoke HeapFree, GetProcessHeap(), 0, [records]
    invoke HeapFree, GetProcessHeap(), 0, [filteredRecords]
    invoke ExitProcess, 0


fetchRecords proc records:DWORD, n:DWORD, year:DWORD, count:DWORD, recordPositions:DWORD
    mov ecx, n
    mov edx, year
    mov ebx, records
    mov eax, 0
    mov [count], eax
    mov esi, 0

filter_records:
    mov eax, [ebx + esi* sizeof RECORD]
    cmp eax, edx
    jne not_matching
    invoke HeapReAlloc, GetProcessHeap(), HEAP_ZERO_MEMORY, [recordPositions], (eax + 1) * sizeof dd
    mov [recordPositions + eax* sizeof dd], esi
    inc eax
    mov [count], eax

not_matching:
    inc esi
    loop filter_records

    invoke HeapAlloc, GetProcessHeap(), HEAP_ZERO_MEMORY, eax * sizeof RECORD
    mov [filteredRecords], eax
    mov ecx, 0

copy_records:
    mov eax, [recordPositions + ecx* sizeof dd]
    mov esi, [records + eax* sizeof RECORD]
    mov [filteredRecords + ecx* sizeof RECORD], esi
    inc ecx
    cmp ecx, [count]
    jl copy_records

    ret
fetchRecords endp

end start
