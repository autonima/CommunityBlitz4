.thumb
.include "_FE8Definitions.h.s"



FreeSelect6C_Loop:
	push 	{r4-r5, r14}

	mov 	r4, r0		@hold onto 6c pointer

	ldr 	r0, =pGameDataStruct
	ldr 	r5, [r0, #0x14]
@cursor movement
	_blh HandlePPCursorMovement

@ (r1, r2) = Cursor Map Pos
	ldr 	r0, =pGameDataStruct
	ldrh 	r1, [r0, #0x14]
	ldrh 	r2, [r0, #0x16]

@ r0 = New Key Presses
	ldr  r0, =pKeyStatusBuffer
	ldrh r0, [r0, #8] @ New Presses

@check for button presses
A_Press_Check:
	mov 	r3, #0x01 @ check if A button was pressed
	tst 	r0, r3
	beq 	NoAPress

	ldr 	r3, [r4, #0x2C]
	ldr 	r3, [r3, #0x0C] @ OnAPress

	cmp 	r3, #0x0
	beq NoAPress

	mov 	r0, r4
	bl BXR3

	b HandleCode

NoAPress:
	mov 	r3, #0x02 @ check if B button was pressed
	tst 	r0, r3
	beq 	NoBPress

	ldr 	r3, [r4, #0x2C]
	ldr 	r3, [r3, #0x10] @ OnBPress

	cmp 	r3, #0x0
	beq NoBPress

	mov 	r0, r4
	bl BXR3

	b HandleCode

NoBPress:
	mov 	r3, #0x1
	lsl 	r3, #0x8	@ check if R button was pressed
	tst 	r0, r3
	beq 	NoRPress

	ldr 	r3, [r4, #0x2C]
	ldr 	r3, [r3, #0x14] @ OnRPress

	cmp 	r3, #0x0
	beq 	NoRPress

	mov 	r0, r4
	bl BXR3

	b HandleCode

NoRPress:
	ldr 	r0, =pGameDataStruct
	ldr 	r0, [r0, #0x14] @ r0 = Cursor Position Pair
	
	cmp 	r0, r5
	beq NoCursorMovement
	
	ldr 	r3, [r4, #0x2C] @ routine array pointer
	ldr 	r3, [r3, #0x08] @ OnPositionChange
	
	cmp 	r3, #0
	beq NoCursorMovement
	
	mov 	r0, r4
	bl BXR3

HandleCode:
	mov 	r5, r0
	
	mov 	r0, #2
	tst 	r5, r0
	beq NoDelete
	
	@ Breaking loop
	mov 	r0, r4
	_blh Break6CLoop
	
	ldr 	r3, [r0, #0x2C]@ routine array pointer
	ldr 	r3, [r3, #0x04]
	
	cmp 	r3, #0
	beq 	NoCall
	
	mov 	r0, r4
	bl BXR3
	
NoCall:
	ldr 	r0, [r4, #0x30]
	_blh TCS_Free
	
	b End @ No need to draw, so go directly to end
	
NoDelete:
	ldr  	r0, =pChapterDataStruct
	add  	r0, #0x41
	ldrb 	r0, [r0]
	
	@ Options set to "no sound effect"
	lsl 	r0, #0x1E
	cmp 	r0, #0x0
	blt 	NoSound
	
	mov 	r0, #4
	tst 	r5, r0
	beq 	NoBeep
	
	mov 	r0, #0x6A
	_blh PlaySound
	
NoBeep:
	mov 	r0, #8
	tst 	r5, r0
	beq NoBoop
	
	mov 	r0, #0x6B
	_blh PlaySound
	
NoBoop:
	mov 	r0, #0x10
	tst 	r5, r0
	beq NoGurr
	
	mov 	r0, #0x6C
	_blh PlaySound
	
NoGurr:
NoSound:
	mov 	r0, #0x20
	tst 	r5, r0
	beq XCursor
	
	ldr r0, [r4, #0x30]
	mov r1, #0x0
	
	_blh TCS_SetAnim
	
	b Finish
	XCursor:
	mov 	r0, #0x40
	tst 	r5, r0
	beq NoCursorMovement
	
	ldr r0, [r4, #0x30]
	mov r1, #0x1
	
	_blh TCS_SetAnim
	
NoCursorMovement:
Finish:
	@ Update Cursor Graphics
	
	ldr r3, =pGameDataStruct
	
	@ Cursor Gfx X
	mov r0, #0x20
	ldsh r1, [r3, r0]
	
	@ Camera X
	mov r0, #0x0C
	ldsh r2, [r3, r0]
	
	@ Draw X
	sub r1, r2
	
	@ Cursor Gfx Y
	mov r0, #0x22
	ldsh r2, [r3, r0]
	
	@ Camera Y
	mov r0, #0x0E
	ldsh r3, [r3, r0]
	
	@ Draw Y
	sub r2, r3
	
	ldr r0, [r4, #0x30]
	_blh TCS_Update

End:
pop 	{r4-r5}
pop 	{r3}

BXR3:
bx	r3

.ltorg
.align

OffsetList:
