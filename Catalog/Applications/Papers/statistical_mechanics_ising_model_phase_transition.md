# Computational Evidence: 1D Ising Two-Point Correlation Function

## Claim under investigation

For the open (free-boundary) 1D Ising chain of `n` bonds (`n+1` sites) with
inverse temperature `β` and coupling `J`, the endpoint two-point correlation is

    ⟨σ₀ σₙ⟩ = (tanh βJ)ⁿ.

Equivalently, the **unnormalised** signed sum

    N(n) = Σ_s sp(s 0) · sp(s last) · ∏ᵢ exp(βJ σᵢ σᵢ₊₁)

equals `2 · (2 sinh βJ)ⁿ`, and since `Z(n) = 2 · (2 cosh βJ)ⁿ`, the ratio is
`(sinh βJ / cosh βJ)ⁿ = (tanh βJ)ⁿ`.

## Small-case calculations (exact, by hand / Lean `#eval`-style)

Let `c = βJ`, `C = cosh c`, `S = sinh c`.

* n = 0 : one site, last = first, σ₀σ₀ = 1.
  N(0) = Σ_{s:Fin1→Bool} sp(s0)² · (empty product = 1) = 1 + 1 = 2.
  `2·(2S)^0 = 2`. ⟨σ₀σ₀⟩ = 2/2 = 1 = (tanh c)^0.  ✓

* n = 1 : two sites, one bond. Four configs (signs · weight):
  (++): (+1)·e^{c},  (+−): (−1)·e^{−c},  (−+): (−1)·e^{−c},  (−−): (+1)·e^{c}.
  N(1) = 2e^{c} − 2e^{−c} = 4 S = 2·(2S)^1.   Z(1) = 2(e^c+e^{-c})·... = 2·(2C).
  ⟨σ₀σ₁⟩ = 4S / (4C) = tanh c = (tanh c)^1.  ✓

* General recursion (peel site 0 with `Fin.cons`):
  Σ_b sp(b) e^{c·sp(b)·sp(t0)} = 2 sp(t0) S   (verified in Lean: sinh is odd).
  Hence N(n+1) = (2S)·N(n), N(0)=2  ⇒  N(n) = 2(2S)^n.   ✓ (verified key step in Lean)

## Connection to correlation length / spectral gap

For β,J>0, `0 < tanh βJ < 1`, so
    ⟨σ₀σₙ⟩ = (tanh βJ)ⁿ = exp(−n·g),   g = −log(tanh βJ) = log(coth βJ) > 0.
This `g` is exactly the transfer-matrix spectral gap `log λ₊ − log λ₋ =
log(2cosh) − log(2sinh)` from `IsingChainPeriodic`. So the correlation length
`ξ = 1/g` is finite at every positive temperature and diverges only as T→0.

## OEIS / counterexample hunt

No integer sequence; the object is a real-analytic function of (β,J). The
universal claim `N(n) = 2(2 sinh βJ)ⁿ` was tested at n=0,1 above and proven by
induction — no counterexample.
