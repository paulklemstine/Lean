load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
# Why do seeds 5000001,5000003,5000004 genfail? Trace the rejection reason.
N, alpha, gamma, b1, b2 = 200, 0.10, 0.70, 0.10, 0.15
for seed in [5000000,5000001,5000002,5000003,5000004]:
    if b2 < b1: bb1, bb2 = b2, b1
    else: bb1, bb2 = b1, b2
    set_random_seed(seed)
    shareN=int(N*gamma); qN=int(N*alpha)
    share_bit = ZZ(randint(2**(shareN-1)+1, 2**shareN-1))
    n1=int(N-N*alpha-N*gamma-N*bb1); n2=int(N-N*alpha-N*gamma-N*bb2)
    MSB4p1=ZZ(randint(2**(n1-1)+1,2**n1-1)); MSB4p2=ZZ(randint(2**(n2-1)+1,2**n2-1))
    p1=random_blum_prime(MSB4p1*2**int(N*gamma+N*bb1)+share_bit*2**int(N*bb1)+2**(int(N*bb1)-1),
                         MSB4p1*2**int(N*gamma+N*bb1)+share_bit*2**int(N*bb1)+2**int(N*bb1)-1)
    p2=random_blum_prime(MSB4p2*2**int(N*gamma+N*bb2)+share_bit*2**int(N*bb2)+2**(int(N*bb2)-1),
                         MSB4p2*2**int(N*gamma+N*bb2)+share_bit*2**int(N*bb2)+2**int(N*bb2)-1)
    q1=random_blum_prime(2**(qN-1),2**qN-1); q2=random_blum_prime(2**(qN-1),2**qN-1)
    print("seed=%d |p1|=%d |p2|=%d |q|=%d  N1=%d N2=%d (want 200)" %
          (seed,p1.nbits(),p2.nbits(),q1.nbits(),(p1*q1).nbits(),(p2*q2).nbits()))
