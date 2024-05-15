
     .code16                  		# Define 16-bit mode
     .global _start			# Define entry point

_start:
	movb $0xe, %ah			# defines BIOS type

	movb $0x48, %al			# loads 'H' ASCII code
	int $0x10			# BIOS interruption

	movb $0x65, %al 		# loads 'E' ASCII code
	int $0x10			# BIOS interruption

	movb $0x6c, %al			# loads 'L' ASCII code
	int $0x10			# BIOS interruption

	movb $0x6c, %al			# loads 'L' ASCII code
	int $0x10			# BIOS interruption

	movb $0x6f, %al			# loads 'O' ASCII code
	int $0x10			# BIOS interruption

	movb $0x20, %al			# loads ' ' ASCII code
	int $0x10			# BIOS interruption

	movb $0x57, %al			# loads 'W' ASCII code
	int $0x10			# BIOS interruption

	movb $0x6f, %al			# loads 'O' ASCII code
	int $0x10			# BIOS interruption

	movb $0x72, %al			# loads 'R' ASCII code
	int $0x10			# BIOS interruption

	movb $0x6c, %al			# loads 'L' ASCII code
	int $0x10			# BIOS interruption

	movb $0x64, %al			# loads 'D' ASCII code
	int $0x10			# BIOS interruption

halt:	
	hlt				# halts
	jmp halt			# safeguard

	.fill 510 - (. - _start), 1, 0	# fills with zeros
	.word 0xaa55        		# Boot signature
