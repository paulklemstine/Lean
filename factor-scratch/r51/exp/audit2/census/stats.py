from scipy.stats import fisher_exact, spearmanr
# E-7 recorded: n=25, p_linked 0.4, ec 0.32 -> 10/25 vs 8/25
tbl=[[10,15],[8,17]]
orr,p = fisher_exact(tbl)
print("E-7 Fisher 10/25 vs 8/25: OR=%.4f  p=%.4f   (census claims p=0.769)"%(orr,p))
# polynomial mass vs relations (I_constant C3)
mass=[11616,6352,4966,8824,6820]; rel=[1090,539,476,425,292]
r=spearmanr(mass,rel)
print("Spearman mass vs relations: rho=%+.4f  p=%.3f  (census says 'anti-correlated')"%(r.statistic,r.pvalue))
print("smallest mass = %d ; census claims the smallest is 6820"%min(mass))
print("sorted by mass:", sorted(zip(mass,rel)))
