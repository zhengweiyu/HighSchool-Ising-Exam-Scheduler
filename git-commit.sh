#!/bin/bash

# HighSchool-Ising-Exam-Scheduler Git 提交脚本
# 使用方法: ./git-commit.sh [commit_message]

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_data() {
    echo -e "${PURPLE}[DATA]${NC} $1"
}

print_api() {
    echo -e "${CYAN}[API]${NC} $1"
}

# 检查是否在Git仓库中
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "当前目录不是Git仓库！"
        exit 1
    fi
}

# 检查是否有未提交的更改
check_changes() {
    if git diff-index --quiet HEAD --; then
        print_warning "没有检测到任何更改"
        return 1
    fi
    return 0
}

# 显示当前状态
show_status() {
    print_step "检查Git状态..."
    git status --short
    echo ""
}

# 添加所有文件到暂存区
add_files() {
    print_step "添加文件到暂存区..."
    git add .
    print_message "所有文件已添加到暂存区"
}

# 提交更改
commit_changes() {
    local commit_message="$1"
    
    if [ -z "$commit_message" ]; then
        # 如果没有提供提交信息，生成默认信息
        commit_message="Update: $(date '+%Y-%m-%d %H:%M:%S') - 高中伊辛模型考试排程项目更新"
    fi
    
    print_step "提交更改..."
    print_message "提交信息: $commit_message"
    
    if git commit -m "$commit_message"; then
        print_message "提交成功！"
        return 0
    else
        print_error "提交失败！"
        return 1
    fi
}

# 推送到远程仓库
push_to_remote() {
    print_step "推送到远程仓库..."
    
    # 获取当前分支名
    current_branch=$(git branch --show-current)
    
    if git push origin "$current_branch"; then
        print_message "推送成功！"
        return 0
    else
        print_error "推送失败！"
        return 1
    fi
}

# 显示提交历史
show_history() {
    print_step "最近5次提交历史..."
    git log --oneline -5
    echo ""
}

# 检查Python相关文件
check_python_files() {
    print_data "检查Python相关文件..."
    
    # 检查是否有Python相关的更改
    if git diff --name-only HEAD | grep -E "\.py$" > /dev/null; then
        print_data "检测到Python代码更改"
        return 0
    fi
    
    return 1
}

# 检查核心算法文件
check_core_files() {
    print_api "检查核心算法文件..."
    
    # 检查是否有核心算法相关的更改
    if git diff --name-only HEAD | grep -E "(ising_exam_scheduler\.py|README\.md)" > /dev/null; then
        print_api "检测到核心算法或文档更改"
        return 0
    fi
    
    return 1
}

# 运行测试（如果存在）
run_tests() {
    if [ -f "ising_exam_scheduler.py" ]; then
        print_step "检查Python代码语法..."
        if python -m py_compile ising_exam_scheduler.py 2>/dev/null; then
            print_message "Python语法检查通过！"
        else
            print_warning "Python语法检查失败，但继续提交..."
        fi
    fi
}

# 检查代码质量
check_code_quality() {
    print_step "检查代码质量..."
    
    # 检查Python语法
    if command -v python > /dev/null 2>&1; then
        # 检查所有Python文件
        python_files=$(git diff --name-only --cached | grep -E "\.py$" || true)
        if [ -n "$python_files" ]; then
            for py_file in $python_files; do
                if [ -f "$py_file" ]; then
                    if python -m py_compile "$py_file" 2>/dev/null; then
                        print_message "$py_file 语法检查通过"
                    else
                        print_warning "$py_file 语法检查失败"
                    fi
                fi
            done
        fi
    fi
}

# 主函数
main() {
    print_message "📚 HighSchool-Ising-Exam-Scheduler Git 提交脚本"
    echo "================================================"
    
    # 检查Git仓库
    check_git_repo
    
    # 显示当前状态
    show_status
    
    # 检查是否有更改
    if ! check_changes; then
        print_warning "没有需要提交的更改"
        show_history
        exit 0
    fi
    
    # 检查Python相关文件
    if check_python_files; then
        print_data "发现Python代码更改，建议仔细检查"
    fi
    
    # 检查核心算法文件
    if check_core_files; then
        print_api "发现核心算法或文档更改，建议仔细检查"
    fi
    
    # 运行测试
    run_tests
    
    # 检查代码质量
    check_code_quality
    
    # 添加文件
    add_files
    
    # 提交更改
    commit_message="$1"
    if ! commit_changes "$commit_message"; then
        exit 1
    fi
    
    # 推送到远程
    if ! push_to_remote; then
        print_warning "推送失败，但本地提交已成功"
        exit 1
    fi
    
    # 显示提交历史
    show_history
    
    print_message "✅ HighSchool-Ising-Exam-Scheduler Git操作完成！"
    print_data "项目已更新到远程仓库"
}

# 显示帮助信息
show_help() {
    echo "HighSchool-Ising-Exam-Scheduler Git 提交脚本"
    echo "============================================="
    echo ""
    echo "使用方法:"
    echo "  $0 [commit_message]"
    echo ""
    echo "参数:"
    echo "  commit_message  可选的提交信息"
    echo ""
    echo "示例:"
    echo "  $0                                    # 使用默认提交信息"
    echo "  $0 '优化模拟退火算法参数'              # 使用自定义提交信息"
    echo "  $0 '修复冲突矩阵计算bug'              # 算法修复"
    echo "  $0 '更新README文档说明'               # 文档更新"
    echo "  $0 '改进能量变化可视化效果'           # 可视化优化"
    echo ""
    echo "功能:"
    echo "  - 自动添加所有更改到暂存区"
    echo "  - 检测Python代码和核心算法文件更改"
    echo "  - 检查Python语法"
    echo "  - 检查代码质量"
    echo "  - 提交更改到本地仓库"
    echo "  - 推送到远程仓库"
    echo "  - 显示Git状态和提交历史"
    echo ""
    echo "特殊功能:"
    echo "  - Python代码更改检测"
    echo "  - 核心算法文件更改检测"
    echo "  - 自动语法检查"
    echo "  - 代码质量检查"
}

# 检查命令行参数
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 执行主函数
main "$1" 