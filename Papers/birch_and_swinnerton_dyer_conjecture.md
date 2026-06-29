# THEOREM TRACE (internal anti-hallucination record)

Every name below is copied verbatim from the Phase A Lean source. Prose in
ARTICLE.md and RESEARCH_PAPER.md only states results that map to one of these.

## LocalFactor.lean (BSD.LocalFactor)
- `localFactor (a p T : ℂ) := 1 - a*T + p*T^2` — local L-factor. [Article §"Euler product"; Paper Def. 1]
- `frobeniusPoly (a p X : ℂ) := X^2 - a*X + p` — characteristic poly of Frobenius. [Paper Def. 2]
- `frobenius_normSq_eq_iff` — root has normSq = p ⇔ a² ≤ 4p (RH over 𝔽_p). [Article §"circle"; Paper Thm 3]
- `frobenius_root_prod` — α·β = p (Vieta). [Paper Lem 4]
- `frobenius_root_sum` — α+β = a (Vieta). [Paper Lem 5]
- `hasse_bound` — a² ≤ 4p ⇒ |a| ≤ 2√p. [Article; Paper Thm 6]
- `localFactor_functional_equation` — L_p(T) = pT²·L_p(1/(pT)). [Paper Thm 7]
- `pointCount (p α β n) := p^n + 1 - (α^n+β^n)`. [Paper Def 8]
- `pointCount_zero`, `pointCount_one`, `pointCount_one_hasse`. [Paper §local]

## FrobeniusTrace.lean (BSD.FrobeniusTrace)
- `power_sum_recurrence` — α^{n+2}+β^{n+2} = a(α^{n+1}+β^{n+1}) - p(α^n+β^n). [Article §"recurrence"; Paper Thm 9]
- `traceSeq (a p) : ℕ→ℂ` with s₀=2, s₁=a, s_{n+2}=a·s_{n+1}-p·s_n. [Paper Def 10]
- `traceSeq_zero`, `traceSeq_one`, `traceSeq_succ_succ`. [Paper §recurrence]
- `traceSeq_eq_power_sum` — traceSeq a p n = α^n+β^n. [Article main; Paper Thm 11]
- `pointCount (a p n) := p^n+1-traceSeq a p n`. [Paper Def 12]
- `pointCount_zero`, `pointCount_one`. [Paper §recurrence]
- `exists_satoTate_angle` — a²≤4p ⇒ ∃θ∈[0,π], a=2√p·cosθ. [Article §"angle"; Paper Thm 13]
- `traceSeq_norm_le` — ‖α^n+β^n‖ ≤ 2(√p)^n. [Article §"RH bound"; Paper Thm 14]

## FunctionalEquation.lean (BSD.FunctionalEquation) — parity mechanism
- Parity theorem: (-1)^{ord_{s=1} Λ} = w for Λ(2-s)=w·Λ(s). [Article §"sign"; Paper Thm 15]
- Corollaries: sign -1 ⇒ central vanishing; even rank ⇔ sign +1. [Paper Cor 16]
- Model L-function (s-1)^r·c with sign (-1)^r. [Paper §nonvacuity]
(Only the stated mathematical content is used; precise Lean identifier kept generic.)

## AnalyticRank.lean (BSD.AnalyticRank)
- `analyticRank L s₀ := analyticOrderNatAt L s₀`. [Paper Def 17]
- `analyticRank_eq_zero_iff` — rank 0 ⇔ L(s₀)≠0. [Article; Paper Thm 18]
- `analyticRank_pos_iff` — rank>0 ⇔ L(s₀)=0. [Paper Thm 19]
- `analyticRank_factorization` — L(z)=(z-s₀)^r·g(z), g(s₀)≠0. [Paper Thm 20]
- `analyticRank_mul` — rank(fg)=rank f + rank g. [Paper Thm 21]
- `modelL`, `modelL_analyticAt`, `modelL_analyticRank`, `modelL_central_value`. [Paper §model]

## RankBridge.lean (BSD.RankBridge)
- `mordellWeil_infinite_iff` — ℤ^r×T infinite ⇔ r>0. [Article §"bridge"; Paper Thm 22]
- `hasse_point_count_pos` — p>1, a²≤4p ⇒ 0 < p+1-a. [Paper Thm 23]
- `bsd_central_vanishing_iff_infinite` — under rank equality, L(1)=0 ⇔ E(ℚ) infinite. [Article main; Paper Thm 24]
- `bsd_nonvanishing_iff_finite` — L(1)≠0 ⇔ E(ℚ) finite. [Paper Cor 25]
- `bridge_realized` — model realizes every rank r. [Paper §nonvacuity]
