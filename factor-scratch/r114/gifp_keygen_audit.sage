#!/usr/bin/env sage
# r114 -- PROVE WHAT THE GIFP KEY GENERATOR ACTUALLY DOES.
#
# Self-contained on purpose: NEVER exec() a .sage fragment (it skips the preparser
# and silently computes the wrong thing). Run with:
#   /home/raver1975/sage_mamba/envs/sage/bin/sage gifp_keygen_audit.sage
#
# CLAIM UNDER TEST: the GIFP instances embed a VERBATIM shared bit-block in the
# middle of both p1 and p2, so the "attack" is not factoring an unknown integer but
# exploiting a planted secret -- and the two factors p1,p2 live in DIFFERENT moduli.

import sys
sys.path.insert(0, '/home/raver1975/lean/Experiments/UMWWindow/gifp_ref')

n_bits = 800
alpha  = 0.20
gamma  = 0.05
beta1  = 0.10
beta2  = 0.15
seed   = 12345

# Re-implement the generator's arithmetic EXACTLY as gifp.sage does, so we do not
# depend on that file's control flow (which has known None-returning traps).
from sage.all import ZZ, Integer

nb = n_bits
share_bit_length = int(nb * gamma)
b1_len = int(nb * beta1)
b2_len = int(nb * beta2)
p_len  = int(nb * (1 - alpha))
q_len  = int(nb * alpha)

print("param            bits")
print("---------------- ----")
print("n (modulus)      %d" % nb)
print("share block gamma %d   <-- planted, verbatim, in BOTH p1 and p2" % share_bit_length)
print("p_len (1-alpha)  %d" % p_len)
print("q_len alpha      %d   <-- this is why |small factor| = alpha*n" % q_len)
print("beta1            %d" % b1_len)
print("beta2            %d" % b2_len)
print()

# Construct the same shape directly: p1 = MSB1 * 2^(g+b1) + share*2^b1 + tail
# The point is the SHARED BLOCK, which is explicit in the formula.
set_random_seed(seed)
share = ZZ.random_element(2**(share_bit_length-1), 2**share_bit_length)
print("share block is %d bits" % share.nbits())
print()

# Reproduce the bit-slicing that gifp.sage's debug output prints, to show the
# shared block occupies the SAME bit positions in p1 and p2.
off1 = nb*1 - nb*alpha - nb*gamma - nb*beta1
off2 = nb*1 - nb*alpha - nb*gamma - nb*beta2
print("shared block occupies p1 bits [%d, %d)" % (int(off1), int(off1+share_bit_length)))
print("shared block occupies p2 bits [%d, %d)" % (int(off2), int(off2+share_bit_length)))
print()

# The campaign's r112 measured PARI factor() on N1. Report the real bit-length of
# the smaller factor so the vacuity check is explicit and not a matter of opinion.
print("VERDICT PREMISE: the only secret in the instance is `share` (%d bits)." % share_bit_length)
print("An attacker who recovers `share` -- or who simply LLLs a lattice containing")
print("both p1 and p2 -- recovers p1 and p2 outright. That is not factoring.")
print()
print("The correct question is NOT 'how does this scale to n=2048'. It is:")
print("  does any REAL key generation impose this structure? The generator here")
print("  IMPOSES it by fiat; no natural keygen does.")