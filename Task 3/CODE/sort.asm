#-------------------- MEMORY Mapped I/O -----------------------
#define PORT_LEDG[7-0] 0x800 - LSB byte (Output Mode)
#define PORT_LEDR[7-0] 0x804 - LSB byte (Output Mode)
#define PORT_HEX0[7-0] 0x808 - LSB byte (Output Mode)
#define PORT_HEX1[7-0] 0x80C - LSB byte (Output Mode)
#define PORT_HEX2[7-0] 0x810 - LSB byte (Output Mode)
#define PORT_HEX3[7-0] 0x814 - LSB byte (Output Mode)
#define PORT_SW[7-0]   0x818 - LSB byte (Input Mode)
#--------------------------------------------------------------
.data 
	Array:  .word 7,6,2,3,12,16,1,4,5,9,8,13,14,10,11,15
	N:	.word 0x5B8D8	# 1.5Mhz clock, 4 commands per dleay = 375,000 times
.text
    addi $s1, $zero, 1	     # $s1 = 1 - to compare with
    la   $t0, Array          # $t0 is the base address. "END" of the array                          
outLoop:             	     # outLoop - used to know if we end sorting
    add  $t1, $zero, $zero   # $t1 = 0 when the list is sorted
    la   $s0, Array          # Set $s0 to base address.
    addi $s0, $s0, 60	     # Set $s0 to last element, start sorting from there
inLoop:                      # inLoop - will iterate over the Array checking if a swap is needed
    lw   $t3, 0($s0)         # t3 = Array[i]
    lw   $t2, -4($s0)        # t2 = Array[i-1]
    slt  $t5, $t3, $t2       # $t5 = 1 if $t3 < $t2	A[i]< A[i-1]
    beq  $t5, $zero, continue# if $t5 = 1, then swap them, meaning DONT jump to continue
    addi $t1, $zero, 1       # If we have swapped, the array is NOT sorted yet. its sorted only when we didnt swap at all
    sw   $t3, -4($s0)        # store the bigger numbers contents in the higher position in array (swap)
    sw   $t2, 0($s0)         # store the smaller numbers contents in the lower position in array (swap)
continue:
    addi $s0, $s0, -4        # advance the array to start at the next location from last time
    slt  $t6, $t0, $s0	     # $t6 = 1 if $t0 < $s0	that means $s0 is not the start of the Array
    beq	 $t6, $s1, inLoop    # if $t6 = 1 (which is s1), than we didnt finish the current loop, $s0 != start of the Array
           	#bne  $s0, $t0, inLoop    # If $s0 != the start of Array, jump back to inLoop
    beq  $t1, $s1, outLoop   # if $t1 = 1 (which is s1), another pass is needed, jump back to outLoop
    		#bne  $t1, $zero, outLoop # $t1 = 1, another pass is needed, jump back to outLoop

# -------- LED SHOW ---------
	addi $s0, $s0, 0
	addi $s1, $s1, 16
	lw   $t3,N
	la   $t5,Array  # array start - $t5 is the address
Loop:	lw   $t0,0($t5) # $t0 has the value of M[$t5]
	sw   $t0,0x800  # write to PORT_LEDG[7-0]
	sw   $t0,0x804  # write to PORT_LEDR[7-0]
	sw   $t0,0x808  # write to PORT_HEX0[7-0]
	sw   $t0,0x80C  # write to PORT_HEX1[7-0]
	sw   $t0,0x810  # write to PORT_HEX2[7-0]
	sw   $t0,0x814  # write to PORT_HEX3[7-0]
	addi $s0,$s0,1   # $s0++
	beq  $s0,$s1,END # till the last element
	addi $t5,$t5,4  # updating $t5 to new address
	move $t1,$zero  # $t1=0
delay:	addi $t1,$t1,1  # $t1=$t1+1
	slt  $t2,$t1,$t3      #if $t1<N than $t2=1
	beq  $t2,$zero,Loop  #if $t1>=N then go to Loop label
	j    delay
END:	addi $t0,$zero,0
	sw   $t0,0x800  # write to PORT_LEDG[7-0]
	sw   $t0,0x804  # write to PORT_LEDR[7-0]
	sw   $t0,0x808  # write to PORT_HEX0[7-0]
	sw   $t0,0x80C  # write to PORT_HEX1[7-0]
	sw   $t0,0x810  # write to PORT_HEX2[7-0]
	sw   $t0,0x814  # write to PORT_HEX3[7-0]
	j    END
