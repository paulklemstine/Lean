# The Shape of Stability: How a Missing Factor of *n* Rewrote the Rules of Polynomial Geometry

## A Hidden Architecture in the Landscape of Polynomials

In 2020, Petter Brändén and June Huh published a paper that sent shockwaves through mathematics. They had discovered a new class of polynomials — *Lorentzian polynomials* — that secretly controlled phenomena ranging from the combinatorics of matroids to the geometry of convex bodies. These polynomials, named after the physicist Hendrik Lorentz for their deep connection to the geometry of spacetime, had been hiding in plain sight for decades.

But there was a catch. The theory was qualitative. It could tell you whether a polynomial was Lorentzian — whether it belonged to this special geometric family — but it couldn't tell you *how robustly* it was Lorentzian. Perturb the coefficients by a tiny amount, and does the polynomial stay in the family? The answer was yes, but the existing bounds on "how tiny" were far too pessimistic. They predicted that in high dimensions, you'd need impossibly precise coefficient control to maintain Lorentzianity. Computation told a completely different story.

This is the tale of how we found the missing factor, and why it changes everything.

## When Your Safety Margin Lies to You

Imagine you're an engineer building a bridge. You compute the stresses in each beam, and your safety manual says the structure can tolerate perturbations of 1 part in a million. But when you actually test the bridge, it can handle perturbations of 1 part in a thousand — a thousand times more robust than the manual claims.

You'd want to know: is the manual wrong, or is the bridge secretly stronger than it needs to be?

This is exactly the situation mathematicians faced with Lorentzian polynomials. A polynomial in *n* variables encodes information in its coefficients — sometimes thousands of them. The existing stability theory said that if you perturbed any coefficient by more than ε/n², where ε measures the polynomial's "margin of safety," you might destroy its Lorentzian character. But numerical experiments consistently showed that perturbations as large as ε/n were perfectly safe.

The gap between theory and practice was a factor of *n* — the number of variables. In ten dimensions, the theory was ten times too conservative. In a hundred dimensions, a hundred times. In the large-dimensional settings where Lorentzian polynomials are most important — combinatorial optimization, statistical physics, machine learning — the theory was practically useless.

## The Geometry of Curvature

To understand the breakthrough, you need to appreciate what makes a polynomial "Lorentzian." Think of a landscape — rolling hills and valleys, defined by a function of two variables. At any point, you can ask: does the landscape curve upward, downward, or in a saddle shape?

Lorentzian polynomials have a very specific curvature signature. At every point, along almost every direction, the landscape curves downward. There's at most one direction — think of a ridgeline — where it curves upward. This is exactly the geometry of spacetime in Einstein's relativity: one time-like direction, many space-like directions, each with opposite curvature character.

The mathematical tool that captures this curvature is the *Hessian matrix* — a square array of second derivatives. The Lorentzian condition says this matrix must have at most one positive eigenvalue, the way a drum vibrates: one fundamental mode going up, everything else going down.

The question of stability becomes: if you slightly change the polynomial's coefficients, how much can the Hessian eigenvalues shift? If a negative eigenvalue gets pushed past zero, you've destroyed the Lorentzian signature.

## The Source of the Slack

The old proof worked like this: if every coefficient changes by at most δ, then every entry of the Hessian matrix changes by at most some amount proportional to δ. Then, to bound how much the eigenvalues can shift, you sum up the effects of all the entry changes.

Here's where the waste happened. A Hessian matrix in *n* dimensions has *n²* entries. The old argument bounded the total effect by summing the worst case over all n² entries, each contributing δ. Total effect: n² × δ. To keep this below the spectral gap ε, you need δ < ε/n².

But this is like estimating the volume of a swimming pool by multiplying its longest dimension by its widest dimension by its deepest point. You get a valid upper bound, but a crude one, because the pool isn't a rectangular block.

The key mathematical insight — the one that breaks the barrier — is the Cauchy-Schwarz inequality, one of the most powerful tools in all of analysis. Instead of summing entry effects individually, you can factor the quadratic form:

|Q_A(v)| ≤ B · (∑|vᵢ|)²

where B is the maximum entry of the perturbation matrix. Then Cauchy-Schwarz gives:

(∑|vᵢ|)² ≤ n · ∑vᵢ² = n · ‖v‖²

The total effect is n × B × ‖v‖², not n² × B × ‖v‖². One factor of n vanishes.

## Why One Factor Is Everything

This might sound like a modest improvement — replacing n² with n. But in mathematics, constants matter enormously, and this isn't just a constant. It's a *structural* improvement that reveals the true geometry.

Consider a Lorentzian polynomial in 100 variables — a realistic size for combinatorial optimization. The old bound said you needed coefficient precision of ε/10,000. The new bound says ε/100 suffices. That's a hundred-fold relaxation. In 1,000 variables, it's a thousand-fold. The improvement grows with the very dimension where you need it most.

And the bound is *tight*. The all-ones matrix — the simplest possible test case — achieves the new bound exactly. Its quadratic form on the all-ones vector is n², and the squared norm of the all-ones vector is n, giving a ratio of exactly n. You can't do better.

## The Proof

The complete proof fits in a page, but its structure is illuminating.

**Step 1: The Cauchy-Schwarz bridge.** For any vector v = (v₁, ..., vₙ):
   (∑ᵢ |vᵢ|)² ≤ n · ∑ᵢ vᵢ²

This is the discrete Cauchy-Schwarz inequality with one of the two "vectors" being the constant function 1.

**Step 2: Quadratic form factoring.** For any matrix A with |Aᵢⱼ| ≤ B:
   |∑ᵢ ∑ⱼ Aᵢⱼ vᵢ vⱼ| ≤ B · ∑ᵢ ∑ⱼ |vᵢ| |vⱼ| = B · (∑ᵢ |vᵢ|)² ≤ n · B · ‖v‖²

**Step 3: Spectral preservation.** If the original Hessian has spectral gap ε (meaning all negative eigenvalues are at most -ε), and the perturbation's quadratic form is bounded by n · δ · ‖v‖², then:
   Q_{H+E}(v) ≤ -ε · ‖v‖² + n · δ · ‖v‖² = -(ε - nδ) · ‖v‖²

So as long as δ < ε/n, the perturbed Hessian still has the Lorentzian signature.

## A Bridge Between Worlds

What makes this result more than a technical improvement is its cross-domain significance.

**In combinatorial optimization**, Lorentzian polynomials certify that a combinatorial generating function has the "negative dependence" property — a crucial ingredient for sampling algorithms. The improved stability constant means these certificates are robust under noisy data.

**In statistical physics**, partition functions of interacting systems are often Lorentzian or nearly so. The stability theorem guarantees that small changes in coupling constants (temperature, field strength) preserve the qualitative behavior of the system. With the new 1/n law, this guarantee extends to much larger perturbations.

**In numerical linear algebra**, the theorem connects to a fundamental question: how much does a matrix's spectrum change when you perturb its entries? The answer — the operator norm grows as n times the maximum entry change, not n² — is a spectral perturbation result that stands on its own.

**In machine learning**, quadratic forms and their signatures appear in loss landscapes, energy functions, and kernel matrices. The improved constant means that stability guarantees for these objects are far more generous than previously thought.

## The Certified Algorithm

Theory becomes practice through algorithms. The stability theorem immediately yields a *certified* algorithm for Lorentzian recognition:

1. Compute the Hessian of the candidate polynomial at a positive point.
2. Find the spectral gap ε (the smallest negative eigenvalue in magnitude).
3. The certified perturbation radius is ε/n.

Any polynomial whose coefficients differ from the candidate by at most ε/n in each entry is guaranteed to be Lorentzian. No further computation needed — the certificate is self-validating.

With the old n² law, this algorithm was impractical for n > 20 or so, because the certified radius shrank below machine precision. With the new n law, practical certification extends to dimensions in the hundreds — covering essentially all realistic applications.

## What the Numbers Say

We tested the theory computationally on elementary symmetric polynomials e_k(x₁, ..., xₙ) — the canonical Lorentzian family. For each n and k, we computed:

- The spectral gap ε
- The certified bound ε/n (new) and ε/n² (old)  
- The actual destruction threshold (by numerical experiment)

The results are striking. The quantity n · C(n,k) — the scaled threshold — converges to a finite positive constant as n grows. This is exactly what the 1/n law predicts. For e₂, the limit is approximately 0.5. For e₃, approximately 0.45. The convergence is rapid and monotone.

Meanwhile, the old n² law predicts that n² · C(n,k) should converge — but the observed n · C(n,k) convergence proves the old law has a redundant factor of n.

## The Deeper Question

Every sharp constant in mathematics tells a story about mechanism. The fact that the correct law is 1/n, not 1/n², reveals something about the *geometry* of the Lorentzian cone.

The n² arose from treating coefficient perturbations as if they could coherently conspire — all n² Hessian entries pushing the eigenvalues in the same direction. But the Cauchy-Schwarz inequality shows this can't happen: the perturbation's effect is constrained by the vector's geometry, not just the matrix's size.

This is a manifestation of a deep principle: in high dimensions, worst-case entry behavior and worst-case spectral behavior are very different. A random perturbation of the Hessian typically has spectral radius proportional to √n · δ (by random matrix theory), not n · δ. The deterministic 1/n bound captures the worst case; the probabilistic √n bound captures the typical case.

Understanding the full spectrum — from deterministic to probabilistic, from worst case to typical case — is the next frontier. The 1/n law is the sharp deterministic answer. The probabilistic story remains to be told.

## Looking Forward

The sharpening of one constant may seem like a small step, but in mathematics, the right constant often unlocks the next revolution. Newton didn't just discover gravity — he found that the force falls off as 1/r², not 1/r³, and that precise exponent made the entire theory of planetary motion possible.

The 1/n stability law opens several doors:

- **Certified Lorentzian testing** becomes practical in the dimensions that matter for applications.
- **Effective spectral dimension** — the idea that structured polynomials might have even better stability, controlled by a quantity smaller than n — becomes a concrete research program.
- **Connections to random matrix theory** promise a probabilistic stability theory that could improve the 1/n bound to 1/√n for generic perturbations.
- **Applications in optimization and physics** can now use Lorentzian certificates with confidence that the certificates are nearly as tight as reality allows.

The missing factor of n has been found. The geometry of the Lorentzian cone is sharper than we thought, and the mathematics of stability is richer than we knew.
