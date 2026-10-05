load('instrument.sage')
n=200
for (alpha,gamma) in [(0.20,0.630),(0.20,0.620),(0.25,0.580),(0.15,0.6617),(0.15,0.670)]:
    aq,gq,b1q,b2q = quantize(alpha,gamma,0.1,0.15,n)
    okc=0
    for sd in range(5):
        gen=generate_gifp_instance(n,RR(aq),RR(gq),RR(b1q),RR(b2q),66000000+sd*7919,max_attempts=10)
        if gen is not None:
            N1l,N2l,sh,ds=gen
            okc+=1
            if sd==0:
                p1,q1,N1=N1l
                print("a=%.2f g=%.3f -> q a=%.3f g=%.3f | N1 bits=%d N2 bits=%d (want %d)" % (
                    alpha,gamma,aq,gq,N1.nbits(),N2l[2].nbits(),n))
    print("   alpha=%.2f gamma=%.3f : %d/5 seeds generated" % (alpha,gamma,okc))
