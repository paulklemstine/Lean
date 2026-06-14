

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "4302919c",
    "description": "# Future Directions \u2014 Closing Carmichael: from the certified band to the asymptotic tail\n\n## Synthesis\n\nThis cycle was about *closing proofs* in the Fibonacci primitive-divisor program.\nOn arrival the Carmichael subsystem was, in fact, not even building: the module\n`Shared.CarmichaelProof` and its dependents imported a `Shared.CarmichaelHelper`\nfile that did not exist, `Speculative.CarmichaelPrimitiveDivisor` imported the\ncomposite module under the wrong path, and the package source root was\nmisconfigured. We repaired all three, then supplied the genuinely missing\nmathematics: the **prime-index case** of Carmichael's theorem.\n\nThe prime case turns out to be elementary once phrased through the\nrank-of-apparition: every prime factor of `F p` (`p` prime) has entry point a\ndivisor of `p`, hence `1` or `p`; the value `1` is impossible because `F 1 = 1`.\nWe proved this in `Shared/CarmichaelHelper.lean` (`fib_primitive_divisor_prime`)\nand then *synthesized* it, in `Speculative/CarmichaelSynthesis.lean`, with the\ntwo other strands already present in the catalog \u2014 the `native_decide`\ncomposite certificate of `Speculative.AutoResearch.CarmichaelComposite` and the\nentry-point theory of the LTE file\n`Algebra.\u2026Fibonacci_Primitive_Divisors`. The synthesis yields a `sorry`-free\nCarmichael theorem on the **certified band** `13 \u2264 n \u2264 10000`, a strengthening\nthat *all* prime factors of `F p` are primitive for prime `p`, the entry-point\nbridge `fibEntryPoint q = p`, and an injectivity corollary giving infinitely\nmany primes as Fibonacci primitive divisors.\n\n## Results summary\n\nFully proved this cycle (`sorry = 0`, only `propext`/`Classical.choice`/`Quot.sound`,\nplus `Lean.ofReduceBool` for the `native_decide` band):\n\n* `CarmichaelHelper.fib_primitive_divisor_prime` \u2014 Carmichael, prime index `\u2265 13`.\n* `CarmichaelSynthesis.fib_all_prime_factors_primitive` \u2014 for prime `p \u2265 3`,\n  *every* prime factor of `F p` is primitive.\n* `CarmichaelSynthesis.fib_carmichael_certified_band` \u2014 Carmichael on `13 \u2264 n \u2264 10000`,\n  glued from the prime branch and the computational composite certificate without\n  touching the open tail.\n* `CarmichaelSynthesis.fib_prime_entryPoint_eq` \u2014 entry point of a prime factor of\n  `F p` equals `p`.\n* `CarmichaelSynthesis.fib_primitive_primes_injective_on_primes` \u2014 distinct prime\n  indices give distinct least primitive primes \u21d2 infinitude.\n\nStill open (one `sorry`, deliberately documented): the **asymptotic composite\ntail** `fib_carmichael_composite` for composite `n > 10000` in\n`Shared/CarmichaelProof.lean`.\n\n## Direction 1 \u2014 Close the composite tail via the cyclotomic/primitive part `\u03a6_n`\n\nThe remaining `sorry` is the infinite composite tail: for composite `n > 10000`,\n`F n` has a primitive prime divisor. The right object is the *primitive part*\n`\u03a6_n := \u220f_{d \u2223 n} F_d ^ \u03bc(n/d)`, the Fibonacci analogue of the cyclotomic value.\n**The key insight is** that, by Lifting-the-Exponent (already formalized as\n`fib_lte`), every prime dividing `\u03a6_n` is primitive *except possibly the largest\nprime factor `P` of `n`, which can occur only to the first power*; hence a single\nsize comparison `\u03a6_n > P` (and `\u03a6_n > 1`) produces a primitive divisor. Concretely:\nprove `\u03a6_n \u2223 F_n`, prove the \"at most one exceptional prime, valuation \u2264 1\"\nlemma from `fib_lte` + `entry_point_dvd_sq_sub_one`, and bound\n`\u03a6_n \u2265 \u03c6^{\u03c6(n)} / C > n \u2265 P` using the existing `fib_exponential_lower_bound`.\n**Why now?** The two hardest ingredients already exist and are `sorry`-free in\nthis very project \u2014 the Fibonacci LTE lemma and the matrix-diagonalization proof\nthat `z(p) \u2223 p\u00b2 \u2212 1`. Only the bookkeeping product `\u03a6_n` and one growth estimate\nare missing, so the tail is now a *finite* assembly task rather than new theory.\n\n## Direction 2 \u2014 Replace `native_decide` on `[13,10000]` by a uniform proof\n\nThe certified band currently rests on a `native_decide` over the coprime-part\nalgorithm. **The key insight is** that the same `\u03a6_n` machinery from Direction 1,\nonce it covers `n > 10000`, almost certainly covers the *entire* range `n \u2265 13`\nwith at most a handful of genuinely exceptional small `n` ({1,2,6,12}), removing\nthe artificial `10000` cutoff and the trust placed in `Lean.ofReduceBool`.\n**Why now?** With `fib_carmichael_certified_band` already isolating the band as a\nstandalone lemma, swapping its proof is a drop-in replacement that cannot regress\nthe public theorem; the cutoff `10000` is exposed as a pure proof artifact, not\nmathematics, making it a clean falsifiable target (does the `\u03a6_n` bound already\nbite at `n = 13`?).\n\n## Direction 3 \u2014 Quantitative primitive divisors: a lower bound on `\u03c9(\u03a6_n)`\n\nBeyond mere existence, Carmichael-type results predict *how many* primitive primes\nappear. **The key insight is** that `\u03a6_n / gcd(\u03a6_n, P)` is a product of distinct\nprimitive primes, so `log \u03a6_n` divided by `log` of the largest Fibonacci prime\nfactor gives an explicit lower bound on the number of primitive prime divisors of\n`F_n`, computable from `fib_exponential_lower_bound`. A falsifiable form: for all\n`n \u2265 30`, `F_n` has at least `2` distinct primitive prime divisors \u2014 testable by\n`#eval` and then provable from the same size estimate. **Why now?** The injectivity\ntheorem `fib_primitive_primes_injective_on_primes` already shows primitivity is the\ncorrect invariant for *counting*; upgrading from \"\u2265 1\" to \"\u2265 k\" reuses exactly the\nentry-point bookkeeping just built.\n\n## Direction 4 \u2014 Transport the entry-point method to Lucas and general Lehmer sequences\n\nThe whole argument used only: a strong divisibility law (`gcd(U_m,U_n)=U_{gcd}`),\nan LTE lemma, and exponential growth. **The key insight is** that these three\nhypotheses can be abstracted into a typeclass `StrongDivisibilitySequence` so that\nthe prime-index Carmichael theorem, the entry-point bridge, and the injectivity\ncorollary become *one* generic proof instantiated by Fibonacci, Lucas `L_n`, and\nMersenne `2^n \u2212 1`. **Why now?** Our prime-case proof already factors through only\n`Nat.fib_gcd` and `Nat.fib_one`; nothing Fibonacci-specific survives, so the\ngeneralization is a refactor that immediately triples the catalog's theorem count\n(Fibonacci \u222a Lucas \u222a Mersenne) at near-zero marginal proof cost \u2014 and it predicts\nthe Bang\u2013Zsygmondy exceptional sets, a sharp falsifiable claim.\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "id": "fd_1814",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "fef5c16a",
    "status": "in_progress",
    "timestamp": "2026-06-14T05:00:59.910734+00:00",
    "title": "This cycle was about *closing proofs* in the Fibonacci primitive-divisor program"
  },
  {
    "consumed_by_exp_id": "c1419c05",
    "description": "Cycle 755f7766 (Q=0.688) proved 33 theorems in Bridges but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: The key insight is that the catalog already contains both an arithmetic height measure on rationals and a categorical bridge from tropical valuation objects to ultranorm objects, but no theorem yet tr",
    "domains": [
      "Bridges"
    ],
    "id": "sorry_fill_755f7766_6cfd798e",
    "priority_score": 0.7379818181818183,
    "research_mode": "team",
    "source_exp_id": "755f7766",
    "status": "in_progress",
    "timestamp": "2026-06-14T03:53:08.702950+00:00",
    "title": "Close Proofs: Ultrametric Lipschitz bounds induced by tropical valuations on arithme"
  },
  {
    "consumed_by_exp_id": "a699fab7",
    "description": "Cycle 25818ba6 (Q=0.502) proved 41 theorems in Applications but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions \u2014 Units, Localness, and the Differential Ring of Combinatorial Species\n\n## Synthesis\n\nThe catalog established the exponential generating function (EGF) as an **isomorphism of\ncommu",
    "domains": [
      "Applications"
    ],
    "id": "sorry_fill_25818ba6_4026dd94",
    "priority_score": 0.5516448780487806,
    "research_mode": "team",
    "source_exp_id": "25818ba6",
    "status": "in_progress",
    "timestamp": "2026-06-14T03:53:27.287731+00:00",
    "title": "Close Proofs: The catalog established the exponential generating function (EGF) as a"
  },
  {
    "consumed_by_exp_id": "74e1359a",
    "description": "Cycle d4cda211 (Q=0.469) proved 51 theorems in Novelty but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: From Height and Width to the Full Order Type of the p-Degrees\n\n## Synthesis\n\nThe order-theoretic core of the Cook\u2013Reckhow program in this catalog now describes the\nposet of p-degr",
    "domains": [
      "Novelty"
    ],
    "id": "sorry_fill_d4cda211_3b490a52",
    "priority_score": 0.5190586232628974,
    "research_mode": "team",
    "source_exp_id": "d4cda211",
    "status": "in_progress",
    "timestamp": "2026-06-14T02:43:33.326798+00:00",
    "title": "Close Proofs: The order-theoretic core of the Cook\u2013Reckhow program in this catalog n"
  },
  {
    "consumed_by_exp_id": "d7fdcbd1",
    "description": "Cycle f8b75e7d (Q=0.460) proved 162 theorems in Applications but left 7 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions \u2014 The Extended Interleaving Metric (Boltzmann Bridge V)\n\n## Synthesis\n\n`Applications/BoltzmannBridge/InterleavingMetric.lean` completes the catalog's\npersistent-homology arc. Boltz",
    "domains": [
      "Applications"
    ],
    "id": "sorry_fill_f8b75e7d_eb309a9e",
    "priority_score": 0.5096093001690941,
    "research_mode": "team",
    "source_exp_id": "f8b75e7d",
    "status": "in_progress",
    "timestamp": "2026-06-14T05:00:46.722767+00:00",
    "title": "Close Proofs: `Applications/BoltzmannBridge/InterleavingMetric.lean` completes the c"
  },
  {
    "consumed_by_exp_id": "996a8ea4",
    "description": "Cycle ab1551a1 (Q=0.456) proved 340 theorems in Bridges but left 12 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: The key insight is that the catalog already contains the two halves of a new bridge theorem \u2014 arithmetic height measures on rational points and tropical-valuation objects inducing ultrametric structur",
    "domains": [
      "Bridges"
    ],
    "id": "sorry_fill_ab1551a1_e33d03ef",
    "priority_score": 0.5055441246550899,
    "research_mode": "team",
    "source_exp_id": "ab1551a1",
    "status": "in_progress",
    "timestamp": "2026-06-14T05:00:09.845877+00:00",
    "title": "Close Proofs: Tropical valuation to ultrametric filtration stability for arithmetic "
  }
];
