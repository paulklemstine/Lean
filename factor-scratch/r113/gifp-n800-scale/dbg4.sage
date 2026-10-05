load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
# Does Sage's multivariate .variables() report variables the poly does NOT use?
pr = ZZ["x","y","z","w"]; x,y,z,w = pr.gens()
g = x^3 + 5
print("g =", g, "| g.variables() =", [str(v) for v in g.variables()], "-> len =", len(g.variables()))
print("univariate_polynomial() on a 4-var ring element:", end=" ")
try:
    print(g.univariate_polynomial())
except Exception as e:
    print("RAISES:", type(e).__name__, e)
h = (x+2*y+3)
print("h.variables() =", [str(v) for v in h.variables()], "len =", len(h.variables()))
