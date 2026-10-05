# n=200,alpha=0.10,m=4 showed round 3/3 but ceil 0/3. t=ceil is supposed to be
# the CORRECT balance, so why does it fail here? Two hypotheses:
#  (H1) at m=4 the ideal t=2.74, so t=ceil=3 == t=round=3 -- they should be
#       IDENTICAL, and any difference is pure noise/bug.
#  (H2) something else differs.
_g=globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'),_g)
_g['__name__']='__main__'
a=RR(0.10); m=4
it=(1-sqrt(a))*m; is_=sqrt(a)*m
print("alpha=0.10 m=4: ideal_t=%.4f -> round=%d ceil=%d ; ideal_s=%.4f -> round=%d ceil=%d"%(
    it,round(it),int(it)+1,is_,round(is_),int(is_)+1))
print("t equal?", round(it)==int(it)+1, " s equal?", round(is_)==int(is_)+1)
