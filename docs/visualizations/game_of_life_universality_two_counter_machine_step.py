def tc_step(program, pc, c1, c2):
    instr = program[pc]
    if instr == 'halt': return None
    elif instr == 'inc1': return (pc+1, c1+1, c2)
    elif instr == 'inc2': return (pc+1, c1, c2+1)
    elif instr[0] == 'dec1_jz':
        return (instr[1], 0, c2) if c1==0 else (pc+1, c1-1, c2)
    elif instr[0] == 'dec2_jz':
        return (instr[1], 0, c2) if c2==0 else (pc+1, c1, c2-1)