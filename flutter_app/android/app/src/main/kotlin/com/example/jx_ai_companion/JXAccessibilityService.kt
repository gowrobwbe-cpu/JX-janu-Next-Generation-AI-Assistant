package com.example.jx_ai_companion

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.graphics.Rect
import android.os.Bundle
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class JXAccessibilityService : AccessibilityService() {

    companion object {
        var instance: JXAccessibilityService? = null
            private set

        fun performGlobal(action: Int): Boolean {
            return instance?.performGlobalAction(action) ?: false
        }

        fun dumpHierarchy(): List<Map<String, Any>> {
            val root = instance?.rootInActiveWindow ?: return emptyList()
            val list = mutableListOf<Map<String, Any>>()
            traverseNode(root, list, 0)
            return list
        }

        private fun traverseNode(node: AccessibilityNodeInfo?, list: mutableListOf<Map<String, Any>>, depth: Int) {
            if (node == null || depth > 8) return
            val rect = Rect()
            node.getBoundsInScreen(rect)

            val text = node.text?.toString() ?: ""
            val desc = node.contentDescription?.toString() ?: ""
            val viewId = node.viewIdResourceName ?: ""
            val isClickable = node.isClickable
            val isScrollable = node.isScrollable

            if (text.isNotEmpty() || desc.isNotEmpty() || isClickable) {
                list.add(
                    mapOf(
                        "text" to text,
                        "contentDescription" to desc,
                        "viewId" to viewId,
                        "className" to (node.className?.toString() ?: ""),
                        "isClickable" to isClickable,
                        "isScrollable" to isScrollable,
                        "bounds" to mapOf(
                            "left" to rect.left,
                            "top" to rect.top,
                            "right" to rect.right,
                            "bottom" to rect.bottom
                        )
                    )
                )
            }

            for (i in 0 until node.childCount) {
                traverseNode(node.getChild(i), list, depth + 1)
            }
        }

        fun findAndClick(targetText: String?, viewId: String?, contentDesc: String?): Boolean {
            val root = instance?.rootInActiveWindow ?: return false

            // 1. By View ID
            if (!viewId.isNullOrEmpty()) {
                val nodes = root.findAccessibilityNodeInfosByViewId(viewId)
                for (node in nodes) {
                    if (clickNodeOrParent(node)) return true
                }
            }

            // 2. By Text
            if (!targetText.isNullOrEmpty()) {
                val nodes = root.findAccessibilityNodeInfosByText(targetText)
                for (node in nodes) {
                    if (clickNodeOrParent(node)) return true
                }
            }

            // 3. By Content Description
            if (!contentDesc.isNullOrEmpty()) {
                val found = findNodeByDescription(root, contentDesc)
                if (found != null && clickNodeOrParent(found)) return true
            }

            return false
        }

        private fun findNodeByDescription(node: AccessibilityNodeInfo?, desc: String): AccessibilityNodeInfo? {
            if (node == null) return null
            if (node.contentDescription?.toString()?.contains(desc, ignoreCase = true) == true) {
                return node
            }
            for (i in 0 until node.childCount) {
                val found = findNodeByDescription(node.getChild(i), desc)
                if (found != null) return found
            }
            return null
        }

        private fun clickNodeOrParent(node: AccessibilityNodeInfo?): Boolean {
            var current = node
            while (current != null) {
                if (current.isClickable) {
                    return current.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                }
                current = current.parent
            }
            // If parent isn't clickable, perform click action directly
            return node?.performAction(AccessibilityNodeInfo.ACTION_CLICK) ?: false
        }

        fun scroll(direction: String): Boolean {
            val root = instance?.rootInActiveWindow ?: return false
            val scrollableNode = findScrollableNode(root) ?: return false
            return if (direction.lowercase() == "up") {
                scrollableNode.performAction(AccessibilityNodeInfo.ACTION_SCROLL_BACKWARD)
            } else {
                scrollableNode.performAction(AccessibilityNodeInfo.ACTION_SCROLL_FORWARD)
            }
        }

        private fun findScrollableNode(node: AccessibilityNodeInfo?): AccessibilityNodeInfo? {
            if (node == null) return null
            if (node.isScrollable) return node
            for (i in 0 until node.childCount) {
                val child = findScrollableNode(node.getChild(i))
                if (child != null) return child
            }
            return null
        }

        fun typeText(targetText: String?, textToType: String): Boolean {
            val root = instance?.rootInActiveWindow ?: return false
            var targetNode: AccessibilityNodeInfo? = null

            if (!targetText.isNullOrEmpty()) {
                val nodes = root.findAccessibilityNodeInfosByText(targetText)
                if (nodes.isNotEmpty()) targetNode = nodes[0]
            }

            if (targetNode == null) {
                targetNode = root.findFocus(AccessibilityNodeInfo.FOCUS_INPUT)
            }

            if (targetNode != null) {
                val args = Bundle().apply {
                    putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, textToType)
                }
                return targetNode.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
            }
            return false
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Accessibility events parsed as needed
    }

    override fun onInterrupt() {
        // Service interrupted
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }
}
