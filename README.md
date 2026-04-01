# 星穹智枢Agent (RAGent AI)

星穹智枢Agent 是一款基于 **Spring Boot 3** 和 **React** 构建的 RAG（检索增强生成）智能体系统。它集成了向量数据库、文档解析、消息队列以及多种大模型驱动，旨在为用户提供私有化、智能化的文档问答与知识库管理体验。

---

## 🌟 核心特性

- **多模型驱动**：支持 阿里云百炼 (Qwen)、SiliconFlow (GLM/Qwen)、Ollama (本地) 等主流 LLM。
- **智能化 RAG**：内置文档切片（Chunking）、嵌入（Embedding）及相似度检索（Vector Search）。
- **知识库管理**：支持 PDF、Word、Markdown 等多种格式的文档上传、解析及向量化。
- **高性能架构**：使用 PostgreSQL (pgvector) 作为向量引擎，Redis 进行缓存，RocketMQ 处理异步分块任务。
- **公网部署**：内置 Ngrok 自动化脚本，秒级实现公网固定 URL 访问。

---

## 🏗️ 技术栈

- **前端**：React 18, Vite, Tailwind CSS, Lucide React
- **后端**：Spring Boot 3.5.7, Maven
- **数据库**：PostgreSQL 16 (pgvector), Redis 7
- **中间件**：RocketMQ 5.3.1, MinIO (对象存储)
- **AI 抽象层**：自定义框架（支持百炼、SiliconFlow 协议）

---

## 🚀 快速启动

### 1. 🌐 公网部署模式 (推荐)
如果你想快速让项目上线并获得一个固定的公网访问地址，请确保已下载 `ngrok.exe` 并放在 `scripts/` 目录下，然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy-ngrok.ps1
```
*   **访问地址**: `https://luggageless-subsynodically-yvonne.ngrok-free.dev`

### 2. 🏠 本地开发调试 (IDEA)
如果你想在 IntelliJ IDEA 中进行代码修改与调试，请按以下步骤操作：

**第一步：启动 Docker 中间件**
```powershell
docker compose up -d postgres redis rocketmq-namesrv rocketmq-broker minio
```

**第二步：配置环境**
- 确保 `.env` 文件中配置了 `BAILIAN_API_KEY` 或 `SILICONFLOW_API_KEY`。
- 后端 IDEA 中使用 `local` Profile。

**第三步：启动应用**
- **后端**: 运行 `BootstrapApplication.java`。
- **前端**: 在 `frontend` 目录下运行 `npm install` && `npm run dev`。

---

## 🛠️ 配置文件说明

- **`docker-compose.yaml`**: 服务编排配置，已处理 RocketMQ 端口冲突。
- **`application-prod.yaml`**: 生产环境配置，适配 Docker 网络。
- **`scripts/deploy-ngrok.ps1`**: 自动化公网部署脚本。

---

## 📦 如何同步代码变更？

当你修改了前端或后端代码后，只需再次运行 `deploy-ngrok.ps1` 脚本，它会自动重新构建镜像、静态资源并重启服务，且公网域名保持不变。

---

## 📝 许可证
[Apache License 2.0](LICENSE)
