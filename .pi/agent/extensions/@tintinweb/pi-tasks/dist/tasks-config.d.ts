export interface TasksConfig {
    taskScope?: "memory" | "session" | "project";
    autoCascade?: boolean;
    autoClearCompleted?: "never" | "on_list_complete" | "on_task_complete";
    showAll?: boolean;
    maxVisible?: number;
    sortOrder?: "id" | "status" | "recent" | "oldest";
    hiddenAt?: "top" | "bottom";
}
export declare function loadTasksConfig(): TasksConfig;
export declare function saveTasksConfig(config: TasksConfig): void;
