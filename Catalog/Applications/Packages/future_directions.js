

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
  },
  {
    "consumed_by_exp_id": "cb2c4d8f",
    "description": "# Future Directions \u2014 Categorical Tropical Rips Interleaving\n\nThis cycle established, in `Catalog/Bridges/CategoricalTropicalRipsInterleaving.lean`, a\nself-contained, fully-verified bridge between **categorical persistence theory**,\n**tropical / min-plus algebra**, and **geometry / topological data analysis**:\n\n- Persistence modules as monotone functors `\u211d \u2192 \u03b1` (`PersMod`).\n- `\u03b5`-interleavings, with reflexivity, symmetry, monotone weakening, and the **composition\n  law** `Interleaved.trans` (`\u03b5`-interleaving \u2218 `\u03b4`-interleaving = `(\u03b5+\u03b4)`-interleaving).\n- The `\u211d\u22650\u221e`-valued **interleaving distance** `interleavingDist`, proven to be a pseudometric\n  (`interleavingDist_self`, `interleavingDist_comm`, `interleavingDist_triangle`).\n- The **tropical reformulation** `interleaving_tropical_submul`: the triangle inequality is\n  *exactly* submultiplicativity of `trop \u2218 interleavingDist` in `Tropical \u211d\u22650\u221e`.\n- **Vietoris\u2013Rips stability** (`rips_stability`, `rips_interleavingDist_le`): sup-close\n  dissimilarities yield interleaved Rips modules.\n\nThe following conjectures are precise, falsifiable targets for the next cycles.\n\n## Conjecture 1 (Isometry / converse stability)\nFor Rips modules of pseudometrics `d, d'` on a fixed point set, the interleaving distance is\n*equal* to (not just bounded by) the sup perturbation:\n`interleavingDist (RipsMod d) (RipsMod d') = ENNReal.ofReal (\u2a06 x y, |d x y - d' x y|)`\nwhenever the sup is finite. **Test:** prove the `\u2265` direction by extracting, from any\n`\u03b5`-interleaving of edge-set modules, the pointwise bound `|d x y - d' x y| \u2264 \u03b5` (evaluate the\ninterleaving at `t = d x y`). This would upgrade \u00a74 to a genuine isometry theorem.\n\n## Conjecture 2 (Tropical semiring action on the distance lattice)\nThe map `(M, N) \u21a6 trop (interleavingDist M N)` is a lax functor into `Tropical \u211d\u22650\u221e`: not only\nsubmultiplicative under composition (proved), but the *self-distance is the tropical unit*\n(`trop 0 = 1` in `Tropical \u211d\u22650\u221e`) and constant shifts act by tropical multiplication, i.e.\n`interleavingDist (shift c M) (shift c N) = interleavingDist M N` and the shift functor `M \u21a6\nshift c M` satisfies `interleavingDist M (shift c M) \u2264 ENNReal.ofReal c`. **Test:** define\n`shift c M := \u27e8fun t => M.obj (t + c), \u2026\u27e9` and prove these three identities.\n\n## Conjecture 3 (Stability is 1-Lipschitz / sub-additive in the tropical metric)\nComposition of perturbations is tropically multiplicative end-to-end: for dissimilarities\n`d, d', d''`,\n`trop (interleavingDist (RipsMod d) (RipsMod d''))\n   \u2264 trop (idist (RipsMod d) (RipsMod d')) * trop (idist (RipsMod d') (RipsMod d''))`,\nand moreover this is *tight* when the perturbations are aligned (same sign everywhere).\n**Test:** the inequality is immediate from Conjecture-free results already proved; the tightness\nclause is the falsifiable content and should be attacked with a 2-point metric space.\n\n## Conjecture 4 (Lattice-valued generalization: persistence in any complete lattice is a\ntropical module)\nFor any complete lattice `\u03b1`, the assignment `\u03b5 \u21a6 {(M,N) | Interleaved \u03b5 M N}` defines a graded\nsub-relation whose graded pieces are closed under min-plus convolution: if `R_\u03b5` and `R_\u03b4` are\nthe `\u03b5`- and `\u03b4`-interleaving relations then `R_\u03b5 \u2218 R_\u03b4 \u2286 R_{\u03b5+\u03b4}` (proved as\n`Interleaved.trans`) and `R = \u22c3_\u03b5 R_\u03b5` is the relation of *finite* interleaving distance, which\nis an equivalence relation refining bisimilarity. **Test:** prove `R` is transitive and that the\nquotient `PersMod \u03b1 / R` carries a well-defined `Tropical \u211d\u22650\u221e`-valued metric.\n\n## Conjecture 5 (Stability of derived invariants: rank/Betti curves are 1-Lipschitz)\nDefine, for a Rips module over a *finite* point set, the rank curve `r(t) = card {(x,y) | d x y\n\u2264 t}`. Then `t \u21a6 r(t)` is monotone and any `\u03b5`-interleaving of Rips modules forces\n`r_d(t) \u2264 r_{d'}(t + \u03b5)` and symmetrically, hence the rank curves are `\u03b5`-interleaved as\n\u2115-valued persistence modules. **Test:** prove the rank functor `PersMod (Set (X\u00d7X)) \u2192 PersMod \u2115`\n(for `Fintype X`) sends `\u03b5`-interleavings to `\u03b5`-interleavings, i.e. it is a 1-Lipschitz functor\nfor the interleaving distance \u2014 a baby \"algebraic stability of the rank invariant\".\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "id": "fd_1945",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "b9cc2fac",
    "status": "in_progress",
    "timestamp": "2026-06-15T09:01:36.127271+00:00",
    "title": "This cycle established, in `Catalog/Bridges/CategoricalTropicalRipsInterleaving."
  },
  {
    "consumed_by_exp_id": "02bb27d8",
    "description": "# FUTURE DIRECTIONS \u2014 Discrete Hodge \u2194 Probability\n\nThis cycle established a self-contained Mathlib foundation for the discrete Hodge\nprogram on finite weighted graphs and bridged it to the probability of reversible\nrandom walks (file `Catalog/Bridges/DiscreteHodgeRandomWalk.lean`).\n\nProved this cycle:\n- Dirichlet energy identity `x\u1d40 L x = \u00bd \u03a3\u1d62\u2c7c w\u1d62\u2c7c (x\u1d62 \u2212 x\u2c7c)\u00b2`.\n- Positive semidefiniteness of the combinatorial Laplacian `L = D \u2212 A`.\n- Symmetry of `L`, zero row-sums, and harmonicity of constants.\n- Detailed balance / reversibility of `P = D\u207b\u00b9A` w.r.t. the degree measure\n  (stated *unconditionally* using totality of real division).\n- The factorization `L f = D(f \u2212 Pf)` and the bridge theorem:\n  at a positive-degree vertex, `(L f) i = 0 \u27fa (P f) i = f i`\n  (discrete harmonic forms = walk-invariant functions).\n\nThe following conjectures are bold, precise, and testable in subsequent cycles.\n\n## C1 \u2014 Kernel of `L` = locally constant functions (connectivity \u21d2 0th Hodge number)\nFor a finite weighted graph whose positive-weight relation is connected,\n`L.mulVec f = 0 \u2194 f` is constant. More generally, `dim ker L` equals the number\nof connected components of the support graph. This is the discrete `H\u2070` and the\n0th Betti number; it is the natural next theorem after `laplacian_mulVec_const`\nand `quadForm_nonneg` (the energy `\u00bd \u03a3 w\u1d62\u2c7c(f\u1d62\u2212f\u2c7c)\u00b2` vanishes iff `f` is constant\non each component).\n\n## C2 \u2014 Spectral gap \u21d2 exponential mixing of the reversible walk\nLet `0 = \u03bb\u2080 \u2264 \u03bb\u2081 \u2264 \u2026 ` be the eigenvalues of the *normalized* Laplacian\n`\ud835\udcdb = I \u2212 D^{-1/2} A D^{-1/2}`. Conjecture: for a connected graph with\n`\u03bb\u2081 > 0`, the reversible walk `P` satisfies a Poincar\u00e9 inequality\n`Var_\u03c0(f) \u2264 (1/\u03bb\u2081) \u00b7 \ud835\udcd4(f, f)` (Dirichlet form), hence `L\u1d56` mixing\n`\u2016P\u1d57f \u2212 \u03c0(f)\u2016 \u2264 (1 \u2212 \u03bb\u2081)\u1d57 \u2016f\u2016`. This connects the Hodge spectrum directly to\nthe probabilistic convergence rate; the Dirichlet identity proved here is the\nexact `\ud835\udcd4(f,f)` appearing in the inequality.\n\n## C3 \u2014 Discrete Hodge decomposition `\u211d^V = ker L \u2295 im L`\nBecause `L` is symmetric PSD, `\u211d^V` orthogonally decomposes as\n`ker L \u2295 range L`, with `ker L` the harmonic part and `range L` the \"exact +\nco-exact\" part. Conjecture (and formalize): every function uniquely splits as\n`f = h + Lg` with `h` harmonic, and `h` is the orthogonal projection minimizing\nDirichlet energy among representatives of `f mod range L`. This is the finite-\ndimensional Hodge theorem; it needs only `Matrix.IsSymm` + PSD already proved.\n\n## C4 \u2014 Reversibility characterizes self-adjointness of `P` in the `\u03c0`-inner product\nConjecture: a stochastic kernel `P` on `Fin n` is reversible w.r.t. a positive\nmeasure `\u03c0` (`\u03c0\u1d62 P\u1d62\u2c7c = \u03c0\u2c7c P\u2c7c\u1d62`) **iff** `P` is self-adjoint for the weighted\ninner product `\u27e8f,g\u27e9_\u03c0 = \u03a3 \u03c0\u1d62 f\u1d62 g\u1d62`, **iff** `P` arises from some symmetric\nweight kernel `w` via `w\u1d62\u2c7c = \u03c0\u1d62 P\u1d62\u2c7c`. This upgrades `reversible` from a property\nof graph-derived walks to a full equivalence, identifying \"reversible Markov\nchain\" with \"weighted graph\" canonically.\n\n## C5 \u2014 Effective resistance is a metric, and a graph-Green's-function identity\nDefine effective resistance `R(i,j)` via the energy-minimizing `g` with\n`L g = e\u1d62 \u2212 e\u2c7c` (well-defined on connected graphs by C3). Conjecture:\n`R` is a metric on vertices (the \"resistance metric\"), `R(i,j) = (e\u1d62\u2212e\u2c7c)\u1d40 L\u207a (e\u1d62\u2212e\u2c7c)`\nwith `L\u207a` the Moore\u2013Penrose pseudoinverse, and it equals the expected commute\ntime of the reversible walk up to the factor `2\u00b7(total weight)`. This is the\ndeepest probability\u2194Hodge bridge: the Green's function `L\u207a` simultaneously\ngoverns harmonic extension (Hodge) and commute/hitting times (probability).\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "id": "fd_1947",
    "priority_score": 0.75,
    "research_mode": "team",
    "source_exp_id": "94b6b70d",
    "status": "in_progress",
    "timestamp": "2026-06-15T09:03:05.891155+00:00",
    "title": "Self-contained Mathlib foundation for the discrete Hodg"
  }
];
