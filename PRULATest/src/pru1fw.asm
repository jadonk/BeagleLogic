/*
 * pru0fw.asm
 *
 * PRU 0 Firmware, for mem transfer
 *
 * This file is a part of the BeagleLogic Project
 * Copyright (C) 2014 Kumar Abhishek <abhishek@theembeddedkitchen.net>
 *
 * This file is free software under GPL v3+
 *
 */

.origin 0
.entrypoint main

#include "prudefs.inc"

.macro NOP
.mstart
	AND R0, R0, R0
.endm

main:
	// Zero all registers, otherwise we might see residual values
	ZERO &R0, 4*29

	// OCP already enabled via PRU0 firmware

	// Set C28 in this PRU's bank =0x24000
	MOV    r0, CTPPR_0+0x2000  // Add 0x2000
	MOV    r1, 0x00000240      // C28 = 00_0240_00h = PRU1 CFG Registers
	SBBO   r1, r0, 0, 4

	// Configure R2 = 0x0000 - PRU1 RAM pointer
	MOV    R2, 0

	// Enable the cycle counter
	LBCO   r0, C28, 0, 4
	SET    r0, 3
	SBCO   r0, C28, 0, 4

	MOV    R1, PRU1_PRU0_INTERRUPT

	// Load Cycle count reading to registers [LBCO=4 cycles, SBCO=2 cycles]
	LBCO   R0, C28, 0x0C, 4
	SBBO   R0, R2, 0, 4

	LBBO   R4, R2, 12, 32

	XOUT   12, R4, 32                       // Push data to Bank0

	LDI    R31, PRU1_PRU0_INTERRUPT + 16    // Signal PRU0, incoming data
	NOP


	LBCO   R3, C28, 0x0C, 4                 // Store PRU1 stalled cycles in PRU1 RAM
	SBBO   R3, R2, 4, 4

	LBCO   R3, C28, 0x10, 4					// Store PRU1 stalled cycles in PRU1 RAM
	SBBO   R3, R2, 8, 4

	HALT
