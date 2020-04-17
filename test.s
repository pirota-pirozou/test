;;; iNES�w�b�_���
  .inesprg 1   ; 1x 16KB PRG
  .ineschr 1   ; 1x  8KB CHR
  .inesmir 1   ; background mirroring
  .inesmap 0   ; mapper 0 = NROM, no bank swapping

;-----------------------------------------------------
; MACRO
;-----------------------------------------------------
; �[���y�[�W���W�X�^�i���j��word����
mov_iw	.macro
		lda	#LOW(\2)
		sta	<\1
		lda	#HIGH(\2)
		sta	<\1+1
		.endm

; �[���y�[�W���W�X�^�i���j��byte����
mov_ib	.macro
		lda	#LOW(\2)
		sta	<\1
		.endm

;-----------------------------------------------------
; �[���y�[�W $0000-$00FF
;-----------------------------------------------------
	.zp
z0	.ds	2
z1	.ds	2

;-----------------------------------------------------
; �X�^�b�N $0100-$01FF
;-----------------------------------------------------

;-----------------------------------------------------
; WORK RAM $0200-$7FFF
;-----------------------------------------------------
	.bss
WORKRAM:
	.ds	$600			; ���ꂪ���[�NRAM�S���I���Ȃ��I



;-----------------------------------------------------
; Code (ROM LOW)
;-----------------------------------------------------

	.code
	.bank 0
	.org $8000

RESET:
	sei
	ldx	#$ff
	txs

; �X�N���[���I�t
    lda #%00010000      ; ���������� VBlank ���荞�݋֎~
    sta $2000
	lda	#$00
	sta	$2001

; WRAM������ ($0000-$07FF)
	lda	#$00
	ldx #$08
WRAMCLR:	
	ldy #$00	;256 times
	sta	<z0
	sta <z0+1
;	mov_iw	z0, 0		; �}�N��
WRAMCLR_0:
	sta	(z0)
	inc	(z0)
	dey
	bne	WRAMCLR_0
	dex
	bne	WRAMCLR

	jsr	vsync			; VSync�҂�

; �p���b�g�e�[�u���֓]��(BG�p�̂ݓ]��)
	lda	#$3f
	sta	$2006
	lda	#$00
	sta	$2006
	ldx	#$00
	ldy	#$10
copypal:
	lda	palettes, x
	sta	$2007
	inx
	dey
	bne	copypal

; �l�[���e�[�u���@�N���A
	lda	#$20			; High
	sta	$2006
	lda	#$00			; Low
	sta	$2006

	ldy	#$10
nameclr:	
	ldx	#$00
	lda	#$00
nameclr_0:
	sta	$2007
	dex
	bne	nameclr_0
	dey
	bne	nameclr

; �X�v���C�g�e�[�u��������
	ldy	#$00
	lda #$00
	sta	$2003		; �X�v���C�g�A�h���X���W�X�^
oam_clr_loop:
	sta $2004		; �X�v���C�g�f�[�^���W�X�^
	dey
	bne	oam_clr_loop

; �l�[���e�[�u���֓]��(��ʂ̒����t��)
	lda	#$21			; High
	sta	$2006
	lda	#$c7			; Low
	sta	$2006
	ldx	#$00
copymap:
	lda	string, x
	beq	copyex
	sta	$2007
	inx
	dey
	bne	copymap

copyex:

; �X�N���[���ݒ�
	lda	#$00
	sta	$2005
	sta	$2005

; �X�N���[���I��
	lda	#$08
	sta	$2000
	lda	#$1e
	sta	$2001
	
;	lda	#%10010000      ; ���荞�݋���
;	sta $2000

; �������[�v
mainloop:
	jmp	mainloop

; VSync �҂�
vsync:
	lda     $2002
    bpl     vsync     ; VBlank���������� $2002 ��7�r�b�g�ڂ�1�ɂȂ�܂őҋ@
	rts

; �p���b�g�e�[�u��
palettes:
	.byte	$0f, $00, $10, $20
	.byte	$0f, $06, $16, $26
	.byte	$0f, $08, $18, $28
	.byte	$0f, $0a, $1a, $2a

; �\��������
string:
	.byte	"HELLO, I'M PIROTA!"
	.byte	0

;;; ���荞�݃x�N�^
	.bank 1
	.org    $FFFA           ; $FFFA ����J�n

	.word	$0000
	.word	RESET
	.word	$0000

;;; �t�H���g�f�[�^��ǂݍ���
  .bank 2
    ;; sprite
    .org    $0000
;  .incbin "character.chr"
; .incbin "sprite.chr"

;; BG
	.byte	$00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00



	.org    $0200
	.incbin "bin/ascii.chr"
