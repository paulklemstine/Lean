

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "consumed_by_exp_id": "afe8c8b6",
    "description": "Cycle 51575ef7 (Q=0.794) proved 68 theorems in Bridges but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: The key insight is that the catalog already contains two independently developed notions of behavioral indistinguishability \u2014 coalgebraic neural behavior in `Bridges/CoalgebraicNeuralMyhillNerode.lean",
    "domains": [
      "Bridges"
    ],
    "id": "sorry_fill_51575ef7_28c2f32a",
    "priority_score": 0.8440000000000001,
    "research_mode": "team",
    "source_exp_id": "51575ef7",
    "status": "in_progress",
    "timestamp": "2026-06-15T06:29:52.059077+00:00",
    "title": "Close Proofs: Functorial comparison between neural observation pseudometrics and pro"
  },
  {
    "consumed_by_exp_id": "842c56ce",
    "description": "Cycle a64f762c (Q=0.705) proved 6 theorems in Bridges but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Salvage the original bridge by shrinking it to a single arithmetic theorem package that is fully self-contained and only depends on elementary `Nat` lemmas plus the existing valuation-depth adapter. D",
    "domains": [
      "Bridges"
    ],
    "id": "sorry_fill_a64f762c_e509fc82",
    "priority_score": 0.7547200000000001,
    "research_mode": "team",
    "source_exp_id": "a64f762c",
    "status": "in_progress",
    "timestamp": "2026-06-15T06:54:22.120757+00:00",
    "title": "Close Proofs: Functorial Lipschitz comparison between valuation depth and tropical v"
  },
  {
    "consumed_by_exp_id": "b221d007",
    "description": "# FUTURE DIRECTIONS \u2014 Functorial Tropical Certificates for Berggren\u2013Lorentz Lattice Reduction\n\nThis cycle established a **functorial tropical certificate** for the Berggren\u2013Lorentz\nmonoid acting on Pythagorean triples\n(`Catalog/Bridges/TropicalBerggrenCertificate.lean`):\n\n- `rowNorm` \u2014 the \u2115-valued L\u221e matrix row-norm \u2014 is **submultiplicative**\n  (`rowNorm_mul_le`).\n- Every Berggren generator has row-norm exactly `7` (`rowNorm_gen`).\n- `wordMatrix` is a genuine **monoid homomorphism** `(List, ++) \u2192 (GL\u2083\u2124, *)`\n  (`wordMatrix_append`), making the certificate functorial.\n- Consequently a depth-`d` triple has all coordinates `\u2264 5\u00b77^d`\n  (`berggren_hypotenuse_certificate`), and `tropCert = log \u2218 rowNorm` is **subadditive**\n  (`tropCert_mul_le`, `tropCert_wordMatrix_le`) \u2014 the tropical/max-plus image of the\n  multiplicative bound.\n\nThe following conjectures are precise and falsifiable; each is intended to seed a\nfollow-up Lean formalization.\n\n## Conjecture 1 (Sharpness of the tropical depth bound)\nThe `7^d` certificate is tight up to the constant: for the all-`B` word `B\u1d48`, the\nhypotenuse of the resulting triple satisfies `c \u2265 5\u00b75^d` and `c \u2264 5\u00b77^d`, and the\nratio `log c / d \u2192 log r` for some `r \u2208 [5,7]`. **Sharper claim:** `r = 1+2\u221a2`\n(the spectral radius / dominant eigenvalue of `matB`), i.e.\n`lim_{d\u2192\u221e} (1/d)\u00b7tropCert(B\u1d48) = log(1+2\u221a2)`. Falsifiable by computing `rowNorm(B\u1d48)`\ngrowth vs. `(1+2\u221a2)^d`.\n\n## Conjecture 2 (Spectral-radius refinement of `rowNorm`)\nFor every Berggren word matrix `M = wordMatrix w`, the *exact* asymptotic growth of\n`rowNorm(M\u1d4f)` as `k\u2192\u221e` is governed by the Perron eigenvalue `\u03bb(M)` of `|M|`, giving a\nstrengthened certificate `tropCert(M\u1d4f) = k\u00b7log \u03bb(M) + O(1)`. This would replace the\nuniform constant `log 7` by a per-word Lyapunov exponent and is the tropical\nlinearization of the Berggren dynamics.\n\n## Conjecture 3 (Reduction is the inverse functor and strictly decreases the certificate)\nDefine the reduction step by the inverse generators `invA, invB, invC` (from Core).\nThen for any non-seed primitive triple `v` with hypotenuse `c > 5`, exactly one inverse\ngenerator strictly decreases the hypotenuse, and the induced reduction word `w\u207b\u00b9`\nsatisfies `tropCert(wordMatrix w\u207b\u00b9) = tropCert(wordMatrix w)` (the certificate is a\ntwo-sided invariant of the word, not just an upper bound). Equivalently: the Berggren\nreduction algorithm terminates in exactly `length(w)` steps, matching the certificate.\n\n## Conjecture 4 (Functorial transfer to ultrametric robustness)\nComposing the tropical certificate with the valuation-reconstruction functor of\n`Bridges/CategoricalTropicalUltrametric.lean` yields a certified ultrametric Lipschitz\nbound: the Berggren action is `7^d`-Lipschitz in the L\u221e metric, and the reconstructed\nultrametric seminorm makes it `1`-Lipschitz (an isometry) after rescaling by the\ntropical certificate. Falsifiable by exhibiting a triple pair whose ultrametric\ndistance is *not* preserved.\n\n## Conjecture 5 (Generalization to higher-dimensional Lorentz monoids)\nFor the O(n-1,1;\u2124) analogue generating Pythagorean (n-1)-tuples, the same L\u221e row-norm\ncertificate holds with uniform generator norm `g(n) = 2n-1` (so `g(3)=7`). The\nfunctorial tropical bound becomes depth `\u2265 log_{2n-1}(c/seed)`. Falsifiable by\nconstructing the n=4 generators (quadruples `a\u00b2+b\u00b2+c\u00b2=d\u00b2`) and checking\n`rowNorm = 9` uniformly.\n",
    "domains": [
      "Physics",
      "Bridges"
    ],
    "id": "fd_1942",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "a37014f1",
    "status": "in_progress",
    "timestamp": "2026-06-15T07:16:41.178841+00:00",
    "title": "**functorial tropical certificate** for the Berggren\u2013Lo"
  }
];
