# When Light Counts Its Own Twists

## A loop, an integer, and a topological memory

A beam of light can carry more than brightness, color, and polarization. Its wavefront can twist like a corkscrew around a dark central line. Such a beam carries orbital angular momentum, and the number of twists is called its **topological charge**. If the twist is right-handed the charge is positive; if it is left-handed the charge is negative. Opposite twists can cancel. Most strikingly, the charge survives many changes in the beam’s ordinary amplitude.

The mathematics behind this behavior begins with a loop in the punctured complex plane. Fix a circle around the beam axis and record the complex field as the azimuthal angle $	heta$ runs from $0$ to $2\pi$. This produces a complex-valued loop $\gamma(\theta)$ that must avoid $0$ along the observation circle. The origin represents zero field amplitude, where phase ceases to be defined. As long as the loop avoids that point, it can wind around it but cannot casually slip across it.

The winding number is measured by the logarithmic-derivative integral

$$
w(\gamma)=\frac{1}{2\pi i}\int_0^{2\pi}\frac{\gamma'(\theta)}{\gamma(\theta)}\,d\theta.
$$

For every smooth, non-vanishing, closed loop, this quantity is an integer. That integer counts the net number of turns around the origin. The formula is not merely a clever way to count. It explains why optical charge is additive, why it is quantized, and exactly when amplitude dressing leaves it unchanged.

## The model vortex

The simplest orbital-angular-momentum phase is

$$
\gamma_\ell(\theta)=e^{i\ell\theta},
$$

where $\ell$ is an integer. During one circuit in physical angle, its value makes $\ell$ circuits in the complex plane. Differentiation gives

$$
\gamma_\ell'(\theta)=i\ell\gamma_\ell(\theta),
$$

so its logarithmic derivative is the constant $i\ell$. Therefore

$$
w(\gamma_\ell)=\frac{1}{2\pi i}\int_0^{2\pi}i\ell\,d\theta=\ell.
$$

This is the first central result: **the winding number of the phase $e^{i\ell\theta}$ is exactly its integer topological charge $\ell$**. Negative charges are every bit as natural as positive ones. They simply describe the opposite handedness.

Why must $\ell$ be integral? A physical phase must return to itself after a complete turn. Since

$$
e^{i\ell(\theta+2\pi)}=e^{i\ell\theta}
$$

precisely when the accumulated phase change is an integral multiple of $2\pi$, single-valuedness enforces quantization. More generally, the winding number of any smooth nonzero closed loop is integral, even if the loop is irregular and has no simple exponential form.

## Multiplication turns into addition

Suppose two non-vanishing fields $\gamma$ and $\delta$ are multiplied pointwise. The ordinary product rule gives

$$
\frac{(\gamma\delta)'}{\gamma\delta}
=\frac{\gamma'}{\gamma}+\frac{\delta'}{\delta}.
$$

Integrating yields the **Winding Product Theorem**:

$$
w(\gamma\delta)=w(\gamma)+w(\delta).
$$

This compact identity is the engine of charge conservation for multiplicatively combined beams. For model phases it says

$$
e^{i\ell\theta}e^{im\theta}=e^{i(\ell+m)\theta},
$$

and the resulting charge is $\ell+m$. For any finite collection with charges $\ell_1,\ldots,\ell_N$, the product field has charge

$$
\ell_1+\cdots+\ell_N.
$$

The distinction between multiplication and addition is essential. Adding two complex fields can create or remove zeros through interference, so winding is not generally additive under pointwise addition. For example, adding a charge-one field to itself merely doubles its amplitude; it does not double its winding. Multiplication combines phase turns, while addition changes the geometry of interference.

Opposite charges reveal the group-like structure vividly. Multiplying $e^{i\ell\theta}$ by $e^{-i\ell\theta}$ gives the constant field $1$. Their charges add to zero, and the phase singularities annihilate in the product. Inversion reverses charge: $w(\gamma^{-1})=-w(\gamma)$.

## The whole beam carries the charge

A real optical beam is not a phase factor floating in isolation. A Laguerre–Gauss-like profile contains a radial amplitude. A simple model is

$$
A_\ell(r,\theta)=r^{|\ell|}e^{i\ell\theta}.
$$

When $\ell\neq 0$, this amplitude vanishes on the axis $r=0$, producing the vortex core. At every positive radius $r>0$, however, the factor $r^{|\ell|}$ is a nonzero constant as $\theta$ traverses the observation circle. Multiplying a loop by any nonzero constant leaves its logarithmic derivative unchanged. Consequently,

$$
w\bigl(A_\ell(r,\cdot)\bigr)=\ell\qquad(r>0).
$$

Thus the charge belongs to the full off-axis physical amplitude, not merely to an artificially separated phase term.

The same idea extends far beyond constant radial factors. Let $L(\theta)$ be a smooth complex function that returns to its initial value after one turn, $L(2\pi)=L(0)$, and dress a beam by the nowhere-zero envelope $e^{L(\theta)}$. Its winding is

$$
w(e^L)=\frac{1}{2\pi i}\int_0^{2\pi}L'(\theta)\,d\theta
=\frac{L(2\pi)-L(0)}{2\pi i}=0.
$$

The product theorem then gives the **Dressing Invariance Theorem**:

$$
w(e^L\gamma)=w(\gamma).
$$

This provides a precise mathematical version of robustness. Smooth changes in radial profile, waist, attenuation, or scalar polarization do not alter charge when they possess a single-valued logarithm that closes after one turn. Mere non-vanishing is not sufficient: an envelope may itself wind around the origin and then contributes its own charge.

## The logarithm detects trivial topology

Locally, every nonzero complex number has a logarithm. Globally around a loop, the logarithm may fail to return to its starting value. That failure is exactly what winding measures.

Call a function $L(\theta)$ a **periodic logarithmic lift** of $\gamma$ if

$$
e^{L(\theta)}=\gamma(\theta),\qquad
L'(\theta)=\frac{\gamma'(\theta)}{\gamma(\theta)},\qquad
L(2\pi)=L(0).
$$

If such a lift exists, the fundamental theorem of calculus immediately gives $w(\gamma)=0$. The converse is deeper but constructive. If $w(\gamma)=0$, define

$$
L(\theta)=\log\gamma(0)+\int_0^\theta\frac{\gamma'(t)}{\gamma(t)}\,dt.
$$

Differentiation shows that $e^{L(\theta)}/\gamma(\theta)$ is constant. Its value at $0$ is $1$, hence $e^{L(\theta)}=\gamma(\theta)$. The zero-winding condition says the integral over a full turn vanishes, so $L(2\pi)=L(0)$.

We therefore obtain the **Logarithmic-Lift Kernel Theorem**: **a smooth non-vanishing loop has winding zero if and only if it admits a periodic logarithmic lift**. This identifies the exact boundary between topologically trivial amplitude variation and genuine optical charge.

There is also a larger structural picture. Winding sends multiplication to addition, sends inverses to negatives, takes only integer values on closed loops, and realizes every integer through $e^{in\theta}$. It is therefore a surjective additive invariant of non-vanishing closed loops. Its zero class consists precisely of loops with closing logarithms.

## Knots meet arithmetic

Twisted light can be engineered so that its singular structure follows torus knots and links. In a simplified $(p,q)$ torus-beam model, the meridional phase has charge $pq$:

$$
\tau_{p,q}(\theta)=e^{ipq\theta},
\qquad
w(\tau_{p,q})=pq.
$$

When the positive integers $p$ and $q$ are coprime, elementary number theory says

$$
\operatorname{lcm}(p,q)=pq.
$$

Hence the **Coprime Torus-Beam Theorem** states that the meridional winding of a coprime $(p,q)$ torus beam equals $\operatorname{lcm}(p,q)$. The trefoil parameters $(2,3)$ give charge

$$
w(\tau_{2,3})=6=\operatorname{lcm}(2,3).
$$

This is a direct bridge between topology and arithmetic. Coprimality is also the condition distinguishing a single torus knot from a multi-component torus link. The identity hints that the familiar relation between greatest common divisor and least common multiple records how total optical charge may be distributed among singular components.

## Reading the invariant numerically

The contour formula also suggests a practical measurement. Sample the complex field at angles $\theta_0,\theta_1,\ldots,\theta_N$ around a closed observation circle, unwrap the successive phase differences into the interval $(-\pi,\pi]$, and add them. Dividing the accumulated phase by $2\pi$ estimates the winding:

$$
\widehat w=\frac{1}{2\pi}\sum_{j=0}^{N-1}\operatorname{Arg}\!\left(\frac{\gamma(\theta_{j+1})}{\gamma(\theta_j)}\right),
$$

where the final sample closes the polygonal loop. For a well-resolved non-vanishing field the result lies close to an integer. This discrete procedure mirrors the continuous logarithmic derivative: each quotient measures a local change of logarithm, and the sum records the global endpoint defect.

There is an important warning. If the sampled field approaches zero, the phase becomes extremely sensitive to noise and a coarse angular grid may miss a rapid turn. The correct response is not to round blindly, but to refine the sampling and check a positive lower bound for the measured amplitude. That caution reflects the topology itself: zero is precisely the point through which winding can change.

Several examples make the rules tangible. Charges $3$ and $-1$ multiply to charge $2$. A family with charges $4,-2,-2,5$ has total charge $5$. Dressing the charge-$3$ beam by $e^{0.4\cos\theta+0.2i\sin\theta}$ changes both magnitude and phase locally, yet the exponent closes and contributes zero net winding. By contrast, dressing it by $e^{-2i\theta}$ shifts the charge to $1$ because that envelope itself winds twice in the opposite direction and has no periodic logarithm.

## A topological memory for light

The winding number ignores countless microscopic details while retaining one global fact: how many times the field encircles zero. This makes topological charge attractive wherever robust labels matter. In optical communication, distinct charges can label channels. In particle manipulation, orbital angular momentum transfers torque. In structured illumination and microscopy, phase singularities organize spatial information. The mathematics explains both the opportunity and the limitation: charge is stable under zero-free dressing, but it can change when the field crosses zero.

The logarithmic derivative is the unifying character. It converts products into sums, turns a full circuit into an endpoint difference, and exposes the obstruction to a global logarithm. From one contour integral emerge quantization, additivity, annihilation, amplitude robustness, and an arithmetic signature for torus beams.

The same viewpoint separates geometry from topology. Two field loops may look utterly different: one nearly circular, another stretched into a narrow, wavering path with strong amplitude modulation. If both avoid zero and can be continuously deformed into one another without touching it, they carry the same charge. Conversely, changing the integer requires a singular episode. Somewhere on the contour, at some stage of the deformation, the field must vanish and its phase must become undefined. Robustness is therefore not mysterious immunity to all disturbance; it is the consequence of a clearly identified forbidden crossing.

Light, in this picture, remembers its twisting not through every detail of its shape but through an integer that cannot change without encountering darkness.