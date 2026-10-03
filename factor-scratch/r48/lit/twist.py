# Check the user's derived identity against the literature (Dieulefait-Urroz p.4)
# N=ab; P=a+1, Q=b+1; a_p, a_q Frobenius traces; t = #E(F_a)#E(F_b) = (P-a_p)(Q-a_q)
# t' for twist with (d/a)=(d/b)=+1 -> (P+a_p)(Q+a_q)
a,b,ap,aq = 101,103,-5,7
P,Q = a+1,b+1
t  = (P-ap)*(Q-aq)
tp = (P+ap)*(Q+aq)   # the "+/+" twist (d square mod both)
print("N+a+b+1 =", a*b+a+b+1, " P*Q =", P*Q)
print("user: t + t' = 2(N+a+b+1) + 2 a_p a_q ->", 2*(a*b+a+b+1)+2*ap*aq, " actual t+t' =", t+tp)
print("user: t - t' = -2[(a+1)a_q + (b+1)a_p] ->", -2*((a+1)*aq+(b+1)*ap), " actual t-t' =", t-tp)
