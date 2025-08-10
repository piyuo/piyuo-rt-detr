# Models

This folder contains pretrained RT-DETRv3 weights and conversion scripts used for **piyuo-rt-detr**.

---

## 📦 Pretrained Weights

Currently included:

| Model                        | Backbone  | Input Size | COCO mAP (val) | Params (M) | FLOPs (G) | Notes                             |
| ---------------------------- | --------- | ---------- | -------------- | ---------- | --------- | --------------------------------- |
| `rtdetrv3_r18vd_6x.pdparams` | ResNet-18 | 640×640    | 48.1           | 20         | 60        | Small and fast for mobile devices |
| `rtdetrv3_r34vd_6x.pdparams` | ResNet-34 | 640×640    | 49.9           | 31         | 92        | Balanced performance vs. speed    |

> **Why only R18 & R34?**
> These backbones provide a good balance of speed and accuracy for mobile deployment.
> R50 and R101 offer higher accuracy but are significantly larger and slower, which is less suitable for mobile devices.

---

## 📥 Download Instructions

The pretrained weights are **not stored in this repository** because they are large files.
You can download them directly from the official [RT-DETRv3 repository](https://github.com/clxia12/RT-DETRv3?tab=readme-ov-file):

1. Go to the **Model Zoo** section of the RT-DETRv3 README.
2. Download:
   - `rtdetrv3_r18vd_6x.pdparams`
   - `rtdetrv3_r34vd_6x.pdparams`
3. Place them in this folder:
models/pretrained/


---

## 🔄 Model Conversion

After downloading `.pdparams` weights, you can convert them:

1. **PaddlePaddle → ONNX**
```bash
python export_onnx.py --weights pretrained/rtdetrv3_r18vd_6x.pdparams
