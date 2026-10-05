load('instrument.sage')
# Authors (gifp.sage:341)  : unknown_modular = M^m * p1^t      <-- correct
# r110/r111 sweeps (line 43): unknown_modular = M^m * N1^t      <-- N1 = p1*q1, WRONG
# Why does it matter? Because f does NOT vanish at the root:
#   f(x0,y0,z0) = M * p1 * q2   (exact, nonzero)  -- verified in dbg_rel2.sage
# so the shift only ever accumulates M^m * p1^t, and NEVER q1^t. Claiming the
# modulus is M^m*N1^t overstates it by q1^t = 2^(alpha*n).
n=200; b1,b2=0.1,0.15
print("  alpha  t   log2(M^m p1^t) [TRUE]  log2(M^m N1^t) [SWEEP]  overestimate")
for alpha,t in [(0.05,3),(0.10,3),(0.14,3),(0.15,2),(0.20,2),(0.25,2)]:
    M = Integer(2**int((b2-b1)*n)); m=4
    aq,gq,b1q,b2q = quantize(alpha,0.5,b1,b2,n)
    gen = generate_gifp_instance(n, RR(aq), RR(gq), RR(b1q), RR(b2q), 42420000+int(alpha*1000), max_attempts=10)
    if gen is None: print(alpha,"skip"); continue
    N1l,N2l,sh,ds = gen; p1,q1,N1=N1l
    true_mod = M**m*p1**t; sweep_mod = M**m*N1**t
    print("  %.2f   %d      %8.1f              %8.1f          %+.1f" % (
        alpha, t, ZZ(true_mod).nbits(), ZZ(sweep_mod).nbits(),
        ZZ(sweep_mod).nbits()-ZZ(true_mod).nbits()))
