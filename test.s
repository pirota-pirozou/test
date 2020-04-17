;;; iNESヘッダ情報
  .inesprg 1   ; 1x 16KB PRG
  .ineschr 1   ; 1x  8KB CHR
  .inesmir 1   ; background mirroring
  .inesmap 0   ; mapper 0 = NROM, no bank swapping

;-----------------------------------------------------
; MACRO
;-----------------------------------------------------
; ゼロページレジスタ（仮）にwordを代入
mov_iw	.macro
		lda	#LOW(\2)
		sta	<\1
		lda	#HIGH(\2)
		sta	<\1+1
		.endm

; ゼロページレジスタ（仮）にbyteを代入
mov_ib	.macro
		lda	#LOW(\2)
		sta	<\1
		.endm

;-----------------------------------------------------
; ゼロページ $0000-$00FF
;-----------------------------------------------------
	.zp
z0	.ds	2
z1	.ds	2

;-----------------------------------------------------
; スタック $0100-$01FF
;-----------------------------------------------------

;-----------------------------------------------------
; WORK RAM $0200-$7FFF
;-----------------------------------------------------
	.bss
WORKRAM:
	.ds	$600			; これがワークRAM全部！少ない！



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

; スクリーンオフ
    lda #%00010000      ; 初期化中は VBlank 割り込み禁止
    sta $2000
	lda	#$00
	sta	$2001

; WRAM初期化 ($0000-$07FF)
	lda	#$00
	ldx #$08
WRAMCLR:	
	ldy #$00	;256 times
	sta	<z0
	sta <z0+1
;	mov_iw	z0, 0		; マクロ
WRAMCLR_0:
	sta	(z0)
	inc	(z0)
	dey
	bne	WRAMCLR_0
	dex
	bne	WRAMCLR

	jsr	vsync			; VSync待ち

; パレットテーブルへ転送(BG用のみ転送)
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

; ネームテーブル　クリア
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

; スプライトテーブル初期化
	ldy	#$00
	lda #$00
	sta	$2003		; スプライトアドレスレジスタ
oam_clr_loop:
	sta $2004		; スプライトデータレジスタ
	dey
	bne	oam_clr_loop

; ネームテーブルへ転送(画面の中央付近)
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

; スクロール設定
	lda	#$00
	sta	$2005
	sta	$2005

; スクリーンオン
	lda	#$08
	sta	$2000
	lda	#$1e
	sta	$2001
	
;	lda	#%10010000      ; 割り込み許可
;	sta $2000

; 無限ループ
mainloop:
	jmp	mainloop

; VSync 待ち
vsync:
	lda     $2002
    bpl     vsync     ; VBlankが発生して $2002 の7ビット目が1になるまで待機
	rts

; パレットテーブル
palettes:
	.byte	$0f, $00, $10, $20
	.byte	$0f, $06, $16, $26
	.byte	$0f, $08, $18, $28
	.byte	$0f, $0a, $1a, $2a

; 表示文字列
string:
	.byte	"HELLO, I'M PIROTA!"
	.byte	0

;;; 割り込みベクタ
	.bank 1
	.org    $FFFA           ; $FFFA から開始

	.word	$0000
	.word	RESET
	.word	$0000

;;; フォントデータを読み込み
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
