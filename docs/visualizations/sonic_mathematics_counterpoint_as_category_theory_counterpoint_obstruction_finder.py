def find_obstruction(n=12, consonant={0,3,4,7,8,9}, perfect={0,7}):
    for i in consonant:
        for j in consonant:
            for du1 in range(n):
                for dl1 in range(n):
                    if (i+du1-dl1)%n != j or not is_valid_vl(i,du1,dl1): continue
                    for k in consonant:
                        for du2 in range(n):
                            for dl2 in range(n):
                                if (j+du2-dl2)%n != k or not is_valid_vl(j,du2,dl2): continue
                                if not is_valid_vl(i,(du1+du2)%n,(dl1+dl2)%n):
                                    return (i,j,k,(du1,dl1),(du2,dl2))
    return None