import React from 'react';
import { ToolExecutionLog } from '../types';
import { Terminal, CheckCircle2, AlertCircle, Clock, Cpu } from 'lucide-react';

interface ToolLogsHUDProps {
  logs: ToolExecutionLog[];
  onClearLogs?: () => void;
}

export const ToolLogsHUD: React.FC<ToolLogsHUDProps> = ({ logs, onClearLogs }) => {
  return (
    <div id="tool-logs-hud" className="w-full h-full min-h-[300px] bg-[#00081433] border border-[#00f2ff1a] rounded p-4 backdrop-blur-sm flex flex-col gap-3 font-mono shadow-xl z-10">
      <div className="flex items-center justify-between border-b border-[#00f2ff1a] pb-2 text-[10px] font-bold tracking-widest text-[#00f2ff88] uppercase">
        <div className="flex items-center gap-2">
          <Terminal className="w-3.5 h-3.5 text-[#00f2ff]" />
          <span>ACTIVE_CORE_TOOLS / EXECUTION_MATRIX</span>
          <span className="bg-[#00f2ff15] text-[#00f2ff] border border-[#00f2ff33] px-2 py-0.5 rounded text-[9px]">
            {logs.length} MATRIX_LOGS
          </span>
        </div>

        {onClearLogs && (
          <button
            id="clear-logs-btn"
            onClick={onClearLogs}
            className="text-[10px] text-[#00f2ff88] hover:text-[#00f2ff] transition-colors uppercase tracking-wider"
          >
            Clear Matrix
          </button>
        )}
      </div>

      <div className="flex-1 overflow-y-auto space-y-2.5 pr-1 max-h-[340px] scrollbar-thin scrollbar-thumb-[#00f2ff22]">
        {logs.length === 0 ? (
          <div className="h-full flex flex-col items-center justify-center text-[#00f2ff55] text-xs py-10 gap-2">
            <Cpu className="w-8 h-8 text-[#00f2ff33] animate-pulse" />
            <span className="text-[10px] uppercase tracking-widest">Awaiting System Tool Invocations...</span>
          </div>
        ) : (
          logs.map((log) => (
            <div
              key={log.id}
              className="p-3 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex flex-col gap-2 transition-all hover:bg-[#00f2ff15]"
            >
              <div className="flex items-center justify-between text-[10px]">
                <div className="flex items-center gap-2 font-bold text-[#e0f2fe] tracking-wider uppercase">
                  {log.status === 'success' ? (
                    <CheckCircle2 className="w-3.5 h-3.5 text-[#00f2ff]" />
                  ) : log.status === 'error' ? (
                    <AlertCircle className="w-3.5 h-3.5 text-[#7000ff]" />
                  ) : (
                    <Clock className="w-3.5 h-3.5 text-[#00f2ff] animate-spin" />
                  )}
                  <span>{log.toolName}</span>
                </div>

                <div className="flex items-center gap-2 text-[#00f2ff88] text-[9px]">
                  <span>{log.timestamp}</span>
                  {log.executionTimeMs !== undefined && (
                    <span className="text-[#00f2ff] font-bold">{log.executionTimeMs} MS</span>
                  )}
                </div>
              </div>

              {/* Input Args */}
              <div className="bg-[#020408] p-2 rounded border border-[#00f2ff1a] text-[10px] text-[#e0f2fe88]">
                <span className="text-[#00f2ff88] select-none uppercase">INPUT_PAYLOAD: </span>
                <span>{JSON.stringify(log.input)}</span>
              </div>

              {/* Output Result */}
              <div className="bg-[#000814cc] p-2 rounded border border-[#00f2ff33] text-[10px] text-[#00f2ff] overflow-x-auto">
                <span className="text-[#7000ff] select-none font-bold uppercase">OUTPUT_RESULT: </span>
                <span>{typeof log.output === 'object' ? JSON.stringify(log.output) : String(log.output)}</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};
