#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 6: FRACTAL COMPRESSION VIA ITERATED FUNCTION SYSTEMS     ║
║  ────────────────────────────────────────────────────────────    ║
║  Exploits self-similarity in data using contractive affine      ║
║  maps. Instead of storing data directly, store the              ║
║  TRANSFORMATIONS that reproduce it.                              ║
║                                                                  ║
║  A 2D signal (image-like) is decomposed into domain-range      ║
║  block pairs where each range block ≈ transformed domain block. ║
║  Decompression iterates the transformations to convergence.     ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np

# ── Generate Test Images ───────────────────────────────────────
def make_test_image(name: str, size: int = 64) -> np.ndarray:
    """Generate synthetic test images with self-similar structure."""
    img = np.zeros((size, size))

    if name == "sierpinski":
        # Sierpinski triangle
        x, y = size // 2, 0
        vertices = [(0, size-1), (size-1, size-1), (size//2, 0)]
        for _ in range(50000):
            vx, vy = vertices[np.random.randint(3)]
            x = (x + vx) // 2
            y = (y + vy) // 2
            if 0 <= x < size and 0 <= y < size:
                img[y, x] = 255

    elif name == "checkerboard":
        # Multi-scale checkerboard (self-similar)
        for scale in [2, 4, 8, 16]:
            block = size // scale
            for i in range(scale):
                for j in range(scale):
                    if (i + j) % 2 == 0:
                        img[i*block:(i+1)*block, j*block:(j+1)*block] += 255 / 4

    elif name == "gradient_fractal":
        # Self-similar gradient pattern
        for i in range(size):
            for j in range(size):
                # Nested sine waves at multiple scales
                val = 0
                for k in range(1, 5):
                    val += np.sin(2 * np.pi * k * i / size) * np.cos(2 * np.pi * k * j / size)
                img[i, j] = (val + 4) / 8 * 255

    elif name == "terrain":
        # Diamond-square fractal terrain
        img[0, 0] = np.random.random() * 255
        img[0, size-1] = np.random.random() * 255
        img[size-1, 0] = np.random.random() * 255
        img[size-1, size-1] = np.random.random() * 255

        step = size - 1
        roughness = 128
        while step > 1:
            half = step // 2
            # Diamond step
            for i in range(half, size, step):
                for j in range(half, size, step):
                    avg = (img[i-half, j-half] + img[i-half, j+half if j+half < size else j] +
                           img[i+half if i+half < size else i, j-half] +
                           img[i+half if i+half < size else i, j+half if j+half < size else j]) / 4
                    img[i, j] = avg + np.random.uniform(-roughness, roughness)
            # Square step
            for i in range(0, size, half):
                for j in range((i + half) % step, size, step):
                    count = 0
                    total = 0
                    for di, dj in [(-half,0),(half,0),(0,-half),(0,half)]:
                        ni, nj = i+di, j+dj
                        if 0 <= ni < size and 0 <= nj < size:
                            total += img[ni, nj]
                            count += 1
                    if count > 0:
                        img[i, j] = total/count + np.random.uniform(-roughness, roughness)
            step = half
            roughness *= 0.5

        img = np.clip(img, 0, 255)

    return img.astype(np.float64)


# ── Fractal Compression ───────────────────────────────────────
class FractalCompressor:
    """
    Fractal image compression using Partitioned IFS.

    Algorithm:
    1. Divide image into non-overlapping RANGE blocks (small)
    2. Create overlapping DOMAIN blocks (larger, downsampled to range size)
    3. For each range block, find the best matching domain block + affine transform
    4. Store only the transform parameters (domain_idx, contrast, brightness, transform_type)
    """

    def __init__(self, range_size: int = 4, domain_size: int = 8):
        self.range_size = range_size
        self.domain_size = domain_size
        self.transforms = []

    def _reduce_block(self, block: np.ndarray) -> np.ndarray:
        """Downsample domain block to range block size."""
        factor = block.shape[0] // self.range_size
        result = np.zeros((self.range_size, self.range_size))
        for i in range(self.range_size):
            for j in range(self.range_size):
                result[i, j] = np.mean(block[i*factor:(i+1)*factor,
                                              j*factor:(j+1)*factor])
        return result

    def _apply_symmetry(self, block: np.ndarray, sym: int) -> np.ndarray:
        """Apply one of 8 symmetry transforms (rotations + flips)."""
        if sym == 0: return block
        if sym == 1: return np.rot90(block, 1)
        if sym == 2: return np.rot90(block, 2)
        if sym == 3: return np.rot90(block, 3)
        if sym == 4: return np.flipud(block)
        if sym == 5: return np.flipud(np.rot90(block, 1))
        if sym == 6: return np.fliplr(block)
        if sym == 7: return np.fliplr(np.rot90(block, 1))
        return block

    def compress(self, image: np.ndarray) -> list:
        """Compress image using fractal encoding."""
        h, w = image.shape
        self.image_shape = (h, w)
        self.transforms = []

        # Extract all domain blocks
        domain_blocks = []
        domain_positions = []
        step = self.range_size  # Domain block stride
        for i in range(0, h - self.domain_size + 1, step):
            for j in range(0, w - self.domain_size + 1, step):
                block = image[i:i+self.domain_size, j:j+self.domain_size]
                reduced = self._reduce_block(block)
                domain_blocks.append(reduced)
                domain_positions.append((i, j))

        # For each range block, find best matching domain block
        n_range_h = h // self.range_size
        n_range_w = w // self.range_size

        for ri in range(n_range_h):
            for rj in range(n_range_w):
                range_block = image[ri*self.range_size:(ri+1)*self.range_size,
                                    rj*self.range_size:(rj+1)*self.range_size]

                best_error = float('inf')
                best_transform = None

                for d_idx, domain in enumerate(domain_blocks):
                    for sym in range(8):
                        transformed = self._apply_symmetry(domain, sym)

                        # Find optimal contrast and brightness
                        # range ≈ contrast * domain + brightness
                        d_flat = transformed.flatten()
                        r_flat = range_block.flatten()

                        d_mean = np.mean(d_flat)
                        r_mean = np.mean(r_flat)
                        d_var = np.var(d_flat)

                        if d_var > 1e-10:
                            contrast = np.sum((d_flat - d_mean) * (r_flat - r_mean)) / (len(d_flat) * d_var)
                            contrast = np.clip(contrast, -1.0, 1.0)  # Contractivity
                        else:
                            contrast = 0.0

                        brightness = r_mean - contrast * d_mean

                        # Compute error
                        approx = contrast * transformed + brightness
                        error = np.mean((range_block - approx) ** 2)

                        if error < best_error:
                            best_error = error
                            best_transform = {
                                'domain_idx': d_idx,
                                'symmetry': sym,
                                'contrast': contrast,
                                'brightness': brightness,
                                'range_pos': (ri, rj),
                            }

                self.transforms.append(best_transform)

        return self.transforms

    def decompress(self, transforms: list, image_shape: tuple,
                    n_iterations: int = 20) -> np.ndarray:
        """Decompress by iterating the IFS to convergence."""
        h, w = image_shape

        # Start with random image
        current = np.random.uniform(0, 255, (h, w))

        for iteration in range(n_iterations):
            new_image = np.zeros((h, w))

            # Reconstruct domain blocks from current image
            domain_blocks = []
            step = self.range_size
            for i in range(0, h - self.domain_size + 1, step):
                for j in range(0, w - self.domain_size + 1, step):
                    block = current[i:i+self.domain_size, j:j+self.domain_size]
                    reduced = self._reduce_block(block)
                    domain_blocks.append(reduced)

            # Apply transforms
            for t in transforms:
                ri, rj = t['range_pos']
                d_idx = t['domain_idx']

                if d_idx >= len(domain_blocks):
                    continue

                domain = domain_blocks[d_idx]
                transformed = self._apply_symmetry(domain, t['symmetry'])
                result = t['contrast'] * transformed + t['brightness']

                new_image[ri*self.range_size:(ri+1)*self.range_size,
                          rj*self.range_size:(rj+1)*self.range_size] = result

            current = np.clip(new_image, 0, 255)

        return current


# ── Analysis Tools ─────────────────────────────────────────────
def psnr(original: np.ndarray, reconstructed: np.ndarray) -> float:
    """Peak Signal-to-Noise Ratio in dB."""
    mse = np.mean((original - reconstructed) ** 2)
    if mse == 0:
        return float('inf')
    return 10 * np.log10(255**2 / mse)

def compression_ratio(original_size: int, n_transforms: int,
                       bytes_per_transform: int = 8) -> float:
    """Estimate compression ratio."""
    compressed_size = n_transforms * bytes_per_transform
    return original_size / max(compressed_size, 1)

def ascii_render(image: np.ndarray, width: int = 60) -> str:
    """Render image as ASCII art."""
    h, w = image.shape
    aspect = h / w
    render_h = int(width * aspect * 0.5)

    chars = " .:-=+*#%@"

    result = []
    for i in range(render_h):
        row = ""
        for j in range(width):
            # Sample from image
            si = int(i / render_h * h)
            sj = int(j / width * w)
            si = min(si, h - 1)
            sj = min(sj, w - 1)
            val = image[si, sj] / 255.0
            char_idx = int(val * (len(chars) - 1))
            char_idx = max(0, min(len(chars) - 1, char_idx))
            row += chars[char_idx]
        result.append("    " + row)

    return "\n".join(result)


# ── Main Demo ──────────────────────────────────────────────────
def main():
    print("=" * 65)
    print("  FRACTAL COMPRESSION via ITERATED FUNCTION SYSTEMS")
    print("=" * 65)

    test_cases = ["checkerboard", "gradient_fractal", "terrain"]

    for name in test_cases:
        print(f"\n  {'─' * 55}")
        print(f"  Test Image: {name.upper()}")
        print(f"  {'─' * 55}")

        np.random.seed(42)
        img = make_test_image(name, size=32)  # Use 32x32 for speed

        print(f"\n  Original ({img.shape[0]}×{img.shape[1]}):")
        print(ascii_render(img, width=40))

        # Compress
        compressor = FractalCompressor(range_size=4, domain_size=8)
        transforms = compressor.compress(img)

        # Decompress
        reconstructed = compressor.decompress(transforms, img.shape, n_iterations=15)

        print(f"\n  Reconstructed (after 15 IFS iterations):")
        print(ascii_render(reconstructed, width=40))

        # Metrics
        p = psnr(img, reconstructed)
        original_bytes = img.shape[0] * img.shape[1]  # 1 byte per pixel
        cr = compression_ratio(original_bytes, len(transforms))

        print(f"\n  Metrics:")
        print(f"    Original size:     {original_bytes:,} bytes")
        print(f"    Transforms:        {len(transforms)}")
        print(f"    Compressed size:   ~{len(transforms) * 8:,} bytes")
        print(f"    Compression ratio: {cr:.2f}:1")
        print(f"    PSNR:              {p:.1f} dB")

        # Show convergence
        print(f"\n  IFS Convergence:")
        for n_iter in [1, 3, 5, 10, 15, 20]:
            recon = compressor.decompress(transforms, img.shape, n_iterations=n_iter)
            p_iter = psnr(img, recon)
            bar = "█" * int(min(p_iter, 40))
            print(f"    Iteration {n_iter:2d}: PSNR = {p_iter:5.1f} dB |{bar}")

    # ── Fractal Generation (IFS) ──────────────────────────────
    print(f"\n\n  {'═' * 55}")
    print(f"  BONUS: IFS FRACTAL GENERATION")
    print(f"  {'═' * 55}")

    # Barnsley Fern
    print(f"\n  Barnsley Fern (IFS with 4 affine transforms):")
    fern = np.zeros((60, 30))
    x, y = 0.0, 0.0

    for _ in range(100000):
        r = np.random.random()
        if r < 0.01:
            x, y = 0, 0.16 * y
        elif r < 0.86:
            x, y = 0.85*x + 0.04*y, -0.04*x + 0.85*y + 1.6
        elif r < 0.93:
            x, y = 0.2*x - 0.26*y, 0.23*x + 0.22*y + 1.6
        else:
            x, y = -0.15*x + 0.28*y, 0.26*x + 0.24*y + 0.44

        px = int((x + 2.5) / 6.0 * 29)
        py = int(y / 10.0 * 59)
        if 0 <= px < 30 and 0 <= py < 60:
            fern[59 - py, px] += 1

    # Normalize and render
    fern = np.clip(fern, 0, np.percentile(fern[fern > 0], 95) if np.any(fern > 0) else 1)
    fern = fern / (fern.max() + 1e-10) * 255
    print(ascii_render(fern, width=35))

    print(f"\n    The fern is encoded by just 4 affine transforms (24 numbers)")
    print(f"    Yet it produces infinite detail at any magnification")
    print(f"\n    ★ This is the essence of fractal compression:")
    print(f"      Store the RULES, not the DATA")
    print("=" * 65)


if __name__ == "__main__":
    main()
