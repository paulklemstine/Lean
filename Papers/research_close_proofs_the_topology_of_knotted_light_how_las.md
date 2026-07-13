# The Topology of Knotted Light: The Winding Number of Orbital-Angular-Momentum Beams

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

A laser beam carrying orbital angular momentum (OAM) — colloquially, *knotted light* — is distinguished by an azimuthal phase factor $e^{i\ell\theta}$ whose integer exponent $\ell$, the *topological charge*, counts how many times the wavefront twists around the beam axis per period. We give a self-contained development of the topological charge as a genuine **winding number**, defined through the classical logarithmic-derivative contour integral $w(\varphi) = \frac{1}{2\pi i}\oint \varphi'/\varphi\,d\theta$. Our central result identifies the winding number of the OAM phase field $e^{i\ell\theta}$ with the integer $\ell$ exactly. From this we obtain quantization of the charge, additivity of charges under beam superposition (multiplication), a conservation law for a family of superposed beams, single-valuedness of the phase field, and a precise statement of the on-axis phase singularity: the physical amplitude $r^{|\ell|}e^{i\ell\theta}$ vanishes on the axis precisely when $\ell \neq 0$ and is nowhere zero off the axis. We further establish two results that overturn plausible-sounding but false conjectures: the topological charge can be negative (optical vortices possess handedness), and the product of two vortex beams of opposite charge is a nonvanishing constant field of winding number zero (the singularities annihilate). Throughout, every statement is accompanied by a complete proof sketch.

**Keywords:** orbital angular momentum, topological charge, winding number, optical vortex, phase singularity, quantization, contour integral, knotted light.

## 1. Introduction

Structured light — beams engineered with spatially varying amplitude, phase, and polarization — has grown from a theoretical curiosity into a mainstay of modern optics. Among the most striking structured beams are those carrying **orbital angular momentum (OAM)**. Whereas an ordinary plane wave has flat wavefronts, an OAM beam has helical wavefronts that spiral around the propagation axis. The signature of this helicity is an azimuthal phase factor $e^{i\ell\theta}$, where $\theta$ is the azimuthal angle around the axis and $\ell \in \mathbb{Z}$ is the **topological charge**.

Physically, $\ell$ counts the number of $2\pi$ phase twists accumulated on one loop around the axis, and each photon in the beam carries orbital angular momentum $\ell\hbar$. The charge $\ell$ is remarkably robust: it is a topological invariant, immune to continuous perturbations of the field that preserve the isolated on-axis zero. This robustness underlies applications ranging from optical trapping and micro-rotation, to high-dimensional classical and quantum communication, to super-resolution microscopy and astronomical coronagraphy.

At the center of an OAM beam lies a **phase singularity**: a point (in cross-section) or line (in three dimensions) where the amplitude vanishes and the phase is undefined. The existence of this dark thread is forced by the twisting of the phase, and the strength of the twist is precisely $\ell$.

This paper formalizes the identification of the topological charge with a mathematical **winding number** and derives its principal algebraic and topological properties from first principles. Our contributions are:

1. A precise definition of the winding number of a loop via the logarithmic-derivative contour integral, and a proof that for the OAM phase field it equals the integer charge (Section 4).
2. Quantization of the topological charge as an immediate corollary (Section 4).
3. The algebra of charges: additivity under superposition, a conservation law over families, and single-valuedness (Sections 3 and 4).
4. A rigorous account of the on-axis phase singularity (Section 5).
5. Two "contrarian" results refuting natural but false conjectures: negativity of the charge and annihilation of opposite vortices (Section 6).

Every result is stated inline with a complete proof sketch, so the development is self-contained.

## 2. Definitions

We work throughout with complex-valued fields of a single real (azimuthal) variable.

**Definition 2.1 (OAM phase field).** For an integer charge $\ell \in \mathbb{Z}$, the *azimuthal phase field* of an OAM beam is the function
$$\varphi_\ell : \mathbb{R} \to \mathbb{C}, \qquad \varphi_\ell(\theta) = e^{i\ell\theta}.$$
It takes values on the unit circle and represents the transverse phase structure of the beam at azimuthal angle $\theta$.

**Definition 2.2 (Beam amplitude profile).** The physical amplitude of a Laguerre–Gauss–like vortex beam, retaining its near-axis radial factor, is
$$A_\ell : \mathbb{R}_{\ge 0} \times \mathbb{R} \to \mathbb{C}, \qquad A_\ell(r,\theta) = r^{|\ell|}\, e^{i\ell\theta},$$
where $r$ denotes the radial distance from the beam axis. The factor $r^{|\ell|}$ encodes the vanishing of intensity at the vortex core.

**Definition 2.3 (Winding number).** For a differentiable loop $\varphi : \mathbb{R} \to \mathbb{C}$ that is nonzero on $[0, 2\pi]$, the *winding number* over one full turn is
$$w(\varphi) = \frac{1}{2\pi i}\int_0^{2\pi} \frac{\varphi'(\theta)}{\varphi(\theta)}\, d\theta.$$
The integrand $\varphi'/\varphi$ is the logarithmic derivative of $\varphi$; its integral measures the total change of $\arg\varphi$ around the loop, and division by $2\pi$ converts this to a count of complete revolutions.

These three definitions suffice for the entire development. All results below concern $\varphi_\ell$, $A_\ell$, and $w$.

## 3. The algebra of OAM phases

We first record the elementary algebraic properties of the phase fields; these hold for all $\theta \in \mathbb{R}$ and require only the functional equation of the exponential.

**Proposition 3.1 (Trivial charge).** $\varphi_0(\theta) = 1$ for all $\theta$.

*Proof.* $\varphi_0(\theta) = e^{i\cdot 0\cdot\theta} = e^0 = 1$. $\square$

**Proposition 3.2 (Additivity of charge under superposition).** For all $\ell, m \in \mathbb{Z}$,
$$\varphi_\ell(\theta)\,\varphi_m(\theta) = \varphi_{\ell + m}(\theta).$$

*Proof.* Using $e^a e^b = e^{a+b}$,
$$e^{i\ell\theta}\,e^{im\theta} = e^{i\ell\theta + im\theta} = e^{i(\ell+m)\theta}. \qquad \square$$

Multiplying two OAM fields therefore corresponds to *adding* their topological charges — the multiplicative structure of the fields mirrors the additive structure of the charges $(\mathbb{Z}, +)$.

**Proposition 3.3 (Opposite charges).** For all $\ell \in \mathbb{Z}$,
$$\varphi_\ell(\theta)\,\varphi_{-\ell}(\theta) = 1.$$

*Proof.* By Proposition 3.2, $\varphi_\ell\varphi_{-\ell} = \varphi_{\ell + (-\ell)} = \varphi_0 = 1$ by Proposition 3.1. $\square$

**Proposition 3.4 (Conservation of total charge).** Let $s$ be a finite index set and $f : s \to \mathbb{Z}$ an assignment of charges. Then
$$\prod_{i \in s} \varphi_{f(i)}(\theta) = \varphi_{\sum_{i \in s} f(i)}(\theta).$$

*Proof.* By induction on $s$. The empty product is $1 = \varphi_0$, matching the empty sum. For the inductive step, on adjoining a new element $a$,
$$\varphi_{f(a)}\prod_{i} \varphi_{f(i)} = \varphi_{f(a)}\,\varphi_{\sum_i f(i)} = \varphi_{f(a) + \sum_i f(i)}$$
by Proposition 3.2, which is $\varphi$ of the new total sum. $\square$

Proposition 3.4 is a conservation law: superposing (multiplying) an arbitrary finite family of OAM beams yields a beam whose charge is the sum of the constituent charges.

**Proposition 3.5 (Single-valuedness / periodicity).** For all $\ell \in \mathbb{Z}$ and $\theta \in \mathbb{R}$,
$$\varphi_\ell(\theta + 2\pi) = \varphi_\ell(\theta).$$

*Proof.* Expand the exponent:
$$i\ell(\theta + 2\pi) = i\ell\theta + i\ell\cdot 2\pi,$$
so $\varphi_\ell(\theta + 2\pi) = e^{i\ell\theta}\,e^{2\pi i\ell}$. Since $\ell$ is an integer, $e^{2\pi i \ell} = 1$, and the claim follows. $\square$

Proposition 3.5 is the physical consistency condition — the field must return to itself after a full revolution — and it is precisely the fact that $\ell \in \mathbb{Z}$ (rather than a fraction) that makes it hold. Fractional charges would render the field multivalued.

## 4. The winding number equals the charge

We now compute the winding number of an OAM phase field. The key computational input is the derivative of $\varphi_\ell$.

**Lemma 4.1 (Derivative of the phase field).** The map $\varphi_\ell$ is differentiable and
$$\varphi_\ell'(\theta) = i\ell\, \varphi_\ell(\theta) = i\ell\, e^{i\ell\theta}.$$

*Proof.* Write $\varphi_\ell = \exp \circ g$ with $g(\theta) = i\ell\theta$ (viewing $\theta \mapsto \theta$ as a real-to-complex embedding). Then $g'(\theta) = i\ell$, and by the chain rule together with the fact that $\exp' = \exp$,
$$\varphi_\ell'(\theta) = g'(\theta)\, e^{g(\theta)} = i\ell\, e^{i\ell\theta}. \qquad \square$$

**Theorem 4.2 (Topological charge = winding number).** For every $\ell \in \mathbb{Z}$,
$$w(\varphi_\ell) = \ell.$$

*Proof.* On the interval of integration the field is nonzero, since $e^{i\ell\theta} \neq 0$ for all $\theta$. By Lemma 4.1 the logarithmic derivative is constant:
$$\frac{\varphi_\ell'(\theta)}{\varphi_\ell(\theta)} = \frac{i\ell\, e^{i\ell\theta}}{e^{i\ell\theta}} = i\ell.$$
Hence
$$w(\varphi_\ell) = \frac{1}{2\pi i}\int_0^{2\pi} i\ell\, d\theta = \frac{1}{2\pi i}\cdot i\ell\cdot 2\pi = \ell. \qquad \square$$

Theorem 4.2 is the central result: the abstract, geometry-laden notion of "how many times the wavefront twists" is recovered exactly by the analytic contour integral, and the answer is the integer $\ell$.

**Corollary 4.3 (Charge quantization).** For every $\ell$ there exists an integer $n$ with $w(\varphi_\ell) = n$; namely $n = \ell$.

*Proof.* Immediate from Theorem 4.2. $\square$

Quantization is thus not an extra hypothesis but a consequence of the definition: the winding integral of an OAM field is always an integer.

**Theorem 4.4 (Additivity of the winding number).** For all $\ell, m \in \mathbb{Z}$,
$$w(\varphi_{\ell + m}) = w(\varphi_\ell) + w(\varphi_m).$$

*Proof.* By Theorem 4.2 each side evaluates as $\ell + m = \ell + m$. $\square$

Combining Theorem 4.4 with Proposition 3.2 shows that superposition of beams (multiplication of fields) adds winding numbers, consistent with the physical conservation of orbital angular momentum.

**Proposition 4.5 (Winding of a constant field).** For any constant $c \in \mathbb{C}$, the constant loop $\theta \mapsto c$ has winding number $0$.

*Proof.* The derivative of a constant is $0$, so the integrand $\varphi'/\varphi = 0$, and the integral — hence the winding number — vanishes. $\square$

## 5. The on-axis phase singularity

The topology of the phase forces a zero of the amplitude on the axis. We make this precise using the amplitude profile $A_\ell(r,\theta) = r^{|\ell|}e^{i\ell\theta}$.

**Theorem 5.1 (Vanishing on the vortex axis).** If $\ell \neq 0$, then for every $\theta$,
$$A_\ell(0, \theta) = 0.$$

*Proof.* Since $\ell \neq 0$, the exponent $|\ell| \in \mathbb{N}$ is nonzero, so $0^{|\ell|} = 0$. Therefore $A_\ell(0,\theta) = 0^{|\ell|}\,e^{i\ell\theta} = 0$. $\square$

**Theorem 5.2 (Nonvanishing off the axis).** For every $\ell \in \mathbb{Z}$ and every $r > 0$,
$$A_\ell(r,\theta) \neq 0.$$

*Proof.* For $r > 0$ the real factor $r^{|\ell|} > 0$, hence nonzero, and $e^{i\ell\theta} \neq 0$ always. A product of nonzero complex numbers is nonzero, so $A_\ell(r,\theta) \neq 0$. $\square$

Together, Theorems 5.1 and 5.2 localize the phase singularity exactly on the axis $r = 0$ and only when $\ell \neq 0$: a charge-zero beam is bright to the center, while every genuine vortex ($\ell \neq 0$) carries an isolated dark thread down its core. The order of the zero is $|\ell|$, matching the strength of the twist.

## 6. Contrarian results

We conclude with two results that refute natural-sounding conjectures, illustrating the subtlety of topological charge.

**Theorem 6.1 (Charge can be negative).** The statement "the real part of $w(\varphi_\ell)$ is nonnegative for every $\ell$" is false.

*Proof.* Take $\ell = -1$. By Theorem 4.2, $w(\varphi_{-1}) = -1$, whose real part is $-1 < 0$. $\square$

Physically, optical vortices possess **handedness**: a beam may spiral clockwise or counterclockwise, and the sign of $\ell$ records the sense of rotation. Negative charge is as physical as positive charge.

**Theorem 6.2 (Annihilation of opposite vortices).** For every $\ell \in \mathbb{Z}$, the superposed field $\theta \mapsto \varphi_\ell(\theta)\,\varphi_{-\ell}(\theta)$ has winding number $0$:
$$w\bigl(\varphi_\ell \cdot \varphi_{-\ell}\bigr) = 0.$$

*Proof.* By Proposition 3.3 the product field is identically $1$. By Proposition 4.5 the winding number of a constant field is $0$. $\square$

**Theorem 6.3 (The annihilated field is singularity-free).** For every $\ell$ and every $\theta$,
$$\varphi_\ell(\theta)\,\varphi_{-\ell}(\theta) \neq 0.$$

*Proof.* By Proposition 3.3 the product equals $1 \neq 0$. $\square$

Theorems 6.2 and 6.3 refute the conjecture that "a product of two vortex beams is again a vortex beam." Two beams of opposite charge $\pm\ell$ combine into a nonvanishing constant field of winding number zero: the two singularities annihilate, leaving ordinary, singularity-free light. This is the optical counterpart of vortex–antivortex annihilation and is consistent with the additivity law $\ell + (-\ell) = 0$.

## 7. Algorithms

The theory yields several directly implementable computations. We summarize the principal ones; full Python implementations accompany this work.

**Algorithm A (Winding number by numerical contour integration).** Given a sampled loop $\varphi$, approximate $w(\varphi) = \frac{1}{2\pi i}\int_0^{2\pi}\varphi'/\varphi\,d\theta$ by finite differences for $\varphi'$ and the trapezoidal rule for the integral, then round the (nearly real-integer) result. This recovers $\ell$ from field data and validates Theorem 4.2 numerically.

**Algorithm B (Charge from phase unwrapping).** Sample $\arg\varphi(\theta)$ around a loop, unwrap the $2\pi$ discontinuities, and divide the net accumulated phase by $2\pi$. This is the practical detector's method for reading topological charge and returns $\ell$ directly.

**Algorithm C (Superposition and annihilation simulator).** Given a list of charges $(\ell_1,\dots,\ell_n)$, form the product field and report its total charge $\sum_i \ell_i$ (Proposition 3.4), flagging the singularity-free case when the total is zero (Theorems 6.2–6.3).

## 8. Applications

- **Optical communications.** Distinct integer charges $\ell$ label mutually orthogonal, topologically protected channels, enabling OAM-multiplexed classical and quantum links with greatly increased capacity.
- **Optical tweezers and micromachines.** The orbital angular momentum $\ell\hbar$ per photon transfers rotation to trapped microparticles, driving optically powered micro-rotors.
- **Microscopy and astronomy.** The on-axis zero (Theorems 5.1–5.2) is exploited in stimulated-emission-depletion microscopy and in optical vortex coronagraphs, where the dark core suppresses an on-axis source.
- **Metrology.** Charge additivity and conservation (Propositions 3.2, 3.4; Theorem 4.4) underpin interferometric measurement of rotational Doppler shifts and of the OAM spectrum of light.

## 9. Discussion

The development shows that the entire near-axis topological content of an OAM beam is captured by a single integer, obtained equivalently by counting phase twists, by evaluating a contour integral (Theorem 4.2), or by observing the order of the on-axis zero (Theorems 5.1–5.2). The algebra of charges is that of the integers under addition (Propositions 3.2, 3.4; Theorem 4.4), and single-valuedness (Proposition 3.5) is exactly the integrality constraint. The contrarian results (Section 6) emphasize that charge carries a sign and can cancel, dispelling two tempting misconceptions.

A conceptual takeaway is that "knotted light" is, in its transverse structure, an incarnation of the fundamental group $\pi_1(\mathbb{C}\setminus\{0\}) \cong \mathbb{Z}$: the winding number classifies loops in the punctured plane, and OAM beams realize each class physically. The topological robustness of $\ell$ — its invariance under continuous perturbation preserving the isolated zero — is the mathematical reason these beams are attractive for information transport.

## 10. Future directions

Several natural extensions remain.

1. **General winding number.** Extend the winding number to a broad class of loops $\gamma : [0,1] \to \mathbb{C}\setminus\{0\}$ and prove homotopy invariance and additivity in full generality (not only for $\varphi_\ell$), connecting to $\mathbb{Z} \cong \pi_1(\mathbb{C}\setminus\{0\})$.
2. **Linking number of nested vortices.** Formalize the Hopf-link / linking-number picture for two coaxial vortex lines and relate it to the product of charges.
3. **Full Laguerre–Gauss modes.** Include the Gaussian envelope and radial index $p$, and prove the OAM per photon is $\ell\hbar$ via the Poynting-vector integral.
4. **Knotted field lines.** Formalize Hopf-fibration constructions of genuinely knotted (rather than merely linked) optical field lines and their conserved helicity/linking invariant.
5. **Stability under perturbation.** Show the charge is invariant under small continuous perturbations of the field that keep the axial zero isolated (topological robustness).

## 11. Conclusion

We have given a self-contained account of the topological charge of orbital-angular-momentum light as a winding number, proving that the winding number of $e^{i\ell\theta}$ is exactly $\ell$, deducing quantization, charge additivity and conservation, single-valuedness, and the precise structure of the on-axis phase singularity, and refuting two natural conjectures by exhibiting negative charge and vortex annihilation. The picture that emerges is uniform and elegant: the twist in a beam of light is a whole number, counted by a contour integral, protected by topology.
