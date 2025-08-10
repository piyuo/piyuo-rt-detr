# piyuo-rt-detr

**piyuo-rt-detr** is an AI model training and benchmarking project built on top of the open-source [RT-DETRv3](https://github.com/clxia12/RT-DETRv3) object detection model.
It is designed for the **Piyuo Counter** application and aims to:

1. Convert pretrained RT-DETRv3 weights to **ONNX** (for ONNX Runtime) and **NCNN** formats.
2. Retrain RT-DETRv3 using images of various resolutions (1024×572, 1024×1024, 1920×1080, 3840×2160, etc.).
3. Benchmark model performance and accuracy against the current production model.
4. Maintain a dataset for retraining.
5. Integrate Google Colab for cloud-based training.

---

## 📂 Project Structure

```
piyuo-rt-detr/
├── data/           # Datasets (raw, processed, annotations)
├── models/         # Weights and conversion scripts
├── training/       # Training configs, scripts, and utilities
├── benchmark/      # Benchmarking tools (C++ and Python)
├── colab/          # Google Colab notebooks
├── scripts/        # Utility scripts
└── README.md
```

---

## 🔄 Workflow Diagram

```text
       ┌───────────────┐
       │  Pretrained   │
       │ RT-DETRv3     │
       │ weights (.pt) │
       └──────┬────────┘
              │
              ▼
   ┌───────────────────┐
   │  Model Conversion  │
   │ export_onnx.py     │
   │ export_ncnn.py     │
   └──────┬─────┬───────┘
          │     │
   (.onnx)│     │(.param/.bin)
          │     │
          ▼     ▼
   ┌───────────────────┐
   │ Benchmarking (C++) │
   │ Compare with       │
   │ current model      │
   └────────┬───────────┘
            │
            ▼
   ┌───────────────────┐
   │  Training (Colab) │
   │  configs/*.yaml   │
   └────────┬──────────┘
            │
            ▼
   ┌───────────────────┐
   │ Retrained Weights │
   │ (.pt, .onnx, NCNN)│
   └────────┬──────────┘
            │
            ▼
   ┌───────────────────┐
   │ Deployment to     │
   │ Piyuo Counter     │
   └───────────────────┘
```

---

## 🚀 Quick Start

1. **Clone the repo**
   ```bash
   git clone https://github.com/yourusername/piyuo-rt-detr.git
   cd piyuo-rt-detr
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Download pretrained weights**
   - Place them in `models/pretrained/`.

4. **Convert to ONNX**
   ```bash
   python models/export_onnx.py --weights models/pretrained/model.pt
   ```

5. **Run benchmark**
   ```bash
   cd benchmark/cpp
   mkdir build && cd build
   cmake ..
   make
   ./benchmark_app
   ```

---

## 📌 Features

- **Multiple format conversion**: PyTorch → ONNX → NCNN.
- **Resolution experiments**: Compare model accuracy/performance across multiple input sizes.
- **C++ and Python benchmarks**: Measure FPS, latency, and accuracy.
- **Colab integration**: Run training without local GPU.
- **Organized datasets**: Store and preprocess images for training.

---

## 📜 License

MIT License – See [LICENSE](LICENSE) for details.
