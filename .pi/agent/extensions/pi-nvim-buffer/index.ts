import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { msgpackRpcCall } from "./rpc";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "nvim_apply_edit",
    description: `Apply an edit to a Neovim buffer via msgpack-rpc. Use this to send code changes back to Neovim instead of editing files on disk.

The tool connects to Neovim's RPC socket and calls nvim_buf_set_lines to replace lines in the target buffer.

Line numbers are 0-indexed. end_line is exclusive (like Neovim's API).

Example: Replace lines 10-15 in buffer 3:
  nvim_socket: "/tmp/nvimXXXXXX/0"
  bufnr: 3
  start_line: 10
  end_line: 15
  replacement: ["line 10 new content", "line 11 new content"]

To insert lines without replacing: set start_line == end_line (insert at that position).
To delete lines: set replacement to an empty array [].`,
    parameters: Type.Object({
      nvim_socket: Type.String({
        description: "Path to the Neovim msgpack-rpc unix socket",
      }),
      bufnr: Type.Number({
        description: "Target buffer number",
      }),
      start_line: Type.Number({
        description: "0-indexed start line (inclusive)",
      }),
      end_line: Type.Number({
        description: "0-indexed end line (exclusive)",
      }),
      replacement: Type.Array(Type.String(), {
        description: "Array of replacement lines (one string per line, no trailing newlines)",
      }),
    }),
    execute: async (
      _toolCallId: string,
      params: {
        nvim_socket: string;
        bufnr: number;
        start_line: number;
        end_line: number;
        replacement: string[];
      },
      _signal?: AbortSignal,
      _onUpdate?: any,
      _ctx?: any,
    ) => {
      const { nvim_socket, bufnr, start_line, end_line, replacement } = params;

      try {
        // Validate buffer is valid
        const isValid = await msgpackRpcCall(
          nvim_socket,
          "nvim_buf_is_valid",
          [bufnr],
          5000
        );

        if (!isValid) {
          return {
            content: [{ type: "text" as const, text: `Error: Buffer ${bufnr} is not valid. It may have been closed.` }],
            details: { success: false },
          };
        }

        // Get buffer name for confirmation message
        const bufName = await msgpackRpcCall(
          nvim_socket,
          "nvim_buf_get_name",
          [bufnr],
          5000
        );

        // Apply the edit via nvim_buf_set_lines
        // Parameters: bufnr, start_line, end_line, strict_indexing, replacement
        await msgpackRpcCall(
          nvim_socket,
          "nvim_buf_set_lines",
          [bufnr, start_line, end_line, false, replacement],
          10000
        );

        const lineCount = end_line - start_line;
        const replacedCount = replacement.length;
        const action = replacedCount === 0 ? "Deleted" : "Replaced";
        const name = bufName || `buffer ${bufnr}`;

        return {
          content: [{ type: "text" as const, text: `${action} lines ${start_line}-${end_line - 1} (${lineCount} lines) with ${replacedCount} lines in ${name}. Edit applied successfully.` }],
          details: { success: true },
        };
      } catch (err: any) {
        return {
          content: [{ type: "text" as const, text: `Error applying edit to buffer ${bufnr}: ${err.message}` }],
          details: { success: false },
        };
      }
    },
  });
}
