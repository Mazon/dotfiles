import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default async function (pi: ExtensionAPI) {
  const baseUrl = "http://localhost:8080/v1";

  // Dynamically discover models from llama.cpp
  let models;
  try {
    const response = await fetch(`${baseUrl}/models`);
    const payload = (await response.json()) as {
      data: Array<{
        id: string;
        name?: string;
        context_window?: number;
        max_tokens?: number;
        meta?: {
          n_ctx?: number;
          n_ctx_train?: number;
        };
      }>;
    };

    models = payload.data.map((model) => ({
      id: model.id,
      name: model.name ?? model.id,
      reasoning: false,
      input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow: model.context_window ?? model.meta?.n_ctx ?? 128000,
      maxTokens: model.max_tokens ?? 4096,
    }));
  } catch {
    // Fallback if llama.cpp is not running at startup
    models = [
      {
        id: "default",
        name: "llama.cpp (default)",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 4096,
      },
    ];
  }

  pi.registerProvider("llama-cpp", {
    name: "llama.cpp (local)",
    baseUrl,
    apiKey: "not-needed",
    api: "openai-completions",
    authHeader: true,
    models,
  });
}
