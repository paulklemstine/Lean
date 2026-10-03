from control import make_instance
from rsa_instances import leak_top_bits, leak_low_bits, leak_p_minus_q
inst=make_instance(256,1)
nb=inst[0].bit_length()
for nl in (0.25,0.5,0.6,0.75):
    k=int(nb*nl)
    t=leak_top_bits(inst,k); l=leak_low_bits(inst,k)
    print("nb(p)=%d leaked=%d  MSB: X=2^%d f=%s...  LSB: X=2^%d f0=%d"%(nb,k,t['X'].bit_length()-1,t['f'][0].bit_length() if t['f'][0] else 0,l['X'].bit_length()-1,l['f'][0]))
d=leak_p_minus_q(inst,0); print("p-q model: recovered=",d['recovered'])
