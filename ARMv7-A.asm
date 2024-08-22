.global main

.section .data
promptNumRecords: .asciz "Number of Records: "
promptRecordYear: .asciz "%d Record Year: "
promptAlbumName: .asciz "%d Album Name: "
promptArtistName: .asciz "%d Artist Name: "
promptFetchYear: .asciz "Enter the year to fetch records: "
resultFormat: .asciz "%d - %d - %s - %s"

    .bss
numRecords: .skip 4
fetchYear: .skip 4
count: .skip 4
recordPositions: .skip 4
filteredRecords: .skip 4

.section .text
main:
    ldr r0, =promptNumRecords
    bl printf
    ldr r0, =numRecords
    bl scanf

    ldr r1, =numRecords
    ldr r1, [r1]

    mul r2, r1, #12
    bl malloc
    str r0, =records

    mov r3, #0
read_records:
    ldr r0, =promptRecordYear
    bl printf
    ldr r1, =records
    add r1, r1, r3, lsl #2
    bl scanf
    ldr r0, =promptAlbumName
    bl printf
    ldr r0, =promptArtistName
    bl printf
    add r3, r3, #1
    cmp r3, r1
    blt read_records

    ldr r0, =promptFetchYear
    bl printf
    ldr r0, =fetchYear
    bl scanf

    ldr r1, =records
    ldr r2, =numRecords
    ldr r2, [r2]
    ldr r3, =fetchYear
    ldr r3, [r3]
    ldr r4, =count
    ldr r5, =recordPositions
    bl fetchRecords

    ldr r6, =recordPositions
    ldr r7, =filteredRecords
    ldr r2, =count
    ldr r2, [r2]
print_records:
    ldr r0, [r6]
    ldr r1, [r7]
    ldr r8, [r7, #4]
    ldr r9, [r7, #8]
    ldr r0, =resultFormat
    bl printf
    add r6, r6, #4
    add r7, r7, #12
    sub r2, r2, #1
    cmp r2, #0
    bne print_records

    ldr r0, =records
    bl free
    ldr r0, =filteredRecords
    bl free
    mov r0, #0
    bl exit

fetchRecords:
    push {r4-r7, lr}

    mov r4, #0
    ldr r5, [sp, #12]
    ldr r6, [sp, #16]
    ldr r7, [sp, #20]

    mov r8, #0
filter_records:
    ldr r0, [r5, r8, lsl #2]
    cmp r0, r6
    bne not_matching
    ldr r1, =recordPositions
    str r8, [r1, r4, lsl #2]
    add r4, r4, #1

not_matching:
    add r8, r8, #1
    cmp r8, r7
    blt filter_records

    mul r0, r4, #12
    bl malloc
    str r0, [sp, #24]

    mov r8, #0
copy_records:
    ldr r0, [recordPositions, r8, lsl #2]
    ldr r1, [records, r0, lsl #2]
    str r1, [filteredRecords, r8, lsl #2]
    add r8, r8, #1
    cmp r8, r4
    blt copy_records

    pop {r4-r7, pc}
