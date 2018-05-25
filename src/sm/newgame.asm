; This skips the intro
org $c2eeda
    db $1f

; Hijack init routine to autosave and set door flags
org $c28067
    jsl introskip_doorflags

org $c0fd00
base $80fd00
introskip_doorflags:
    ; Do some checks to see that we're actually starting a new game
    
    ; Make sure game mode is 1f
    lda $7e0998
    cmp.w #$001f
    beq +
    jmp .ret
+

    ; Check if samus saved energy is 00, if it is, run startup code
    lda $7ed7e2
    beq +
    jmp .ret

+
    ; Set construction zone and red tower elevator doors to blue
    lda $7ed8b6
    ora.w #$0004
    sta $7ed8b6    
    lda $7ed8b2
    ora.w #$0001
    sta $7ed8b2

    ; Unlock crateria map station door
    lda $7ed8b0
    ora.w #$0020
    sta $7ed8b0

    ; Unlock norfair map station door
    lda $7ed8b8
    ora.w #$1000
    sta $7ed8b8

    ; Set up open mode event bit flags
    lda #$0001
    sta $7ed820
    
    lda #$0000
    sta.l !SRAM_SM_COMPLETED
    sta.l !SRAM_ALTTP_EQUIPMENT_1
    sta.l !SRAM_ALTTP_EQUIPMENT_2
    sta.l !SRAM_ALTTP_COMPLETED
    sta.l !SRAM_ALTTP_RANDOMIZER_SAVED
    sta.l !door_timer_tmp
    sta.l !door_adjust_tmp
    sta.l !add_time_tmp
    sta.l !region_timer_tmp
    sta.l !region_tmp
    sta.l !transition_tmp
    
    jsl stats_clear_values  ; Clear SM stats
    jsl alttp_new_game      ; Setup new game for ALTTP
    jsl sm_copy_alttp_items ; Copy alttp items into temporary SRAM buffer
    jsl zelda_fix_checksum  ; Fix alttp checksum

    ; set all map stations as "acquired," in other words the maps will always show up
    %a8()
    lda.b #$FF
    sta.l $7ED908
    sta.l $7ED909
    sta.l $7ED90A
    sta.l $7ED90B
    sta.l $7ED90C
    sta.l $7ED90D
    sta.l $7ED90E
    sta.l $7ED90F  
    %a16()

    ; Call the save code to create a new file
    lda $7e0952
    jsl $818000

.ret:   
    lda #$0000
    rtl