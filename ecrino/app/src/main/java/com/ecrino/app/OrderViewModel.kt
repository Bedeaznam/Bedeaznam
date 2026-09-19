package com.ecrino.app

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.launch

/**
 * Owns the in-flight submission so it survives activity recreation: a rotation
 * mid-request neither cancels the delivery nor lets a second tap duplicate it.
 */
class OrderViewModel : ViewModel() {

    private val _submitting = MutableStateFlow(false)
    val submitting: StateFlow<Boolean> = _submitting.asStateFlow()

    private val _results = Channel<SubmitResult>(Channel.BUFFERED)
    val results = _results.receiveAsFlow()

    fun submit(context: Context, order: OrderRequest) {
        if (_submitting.value) return
        _submitting.value = true
        val appContext = context.applicationContext
        viewModelScope.launch {
            val result = OrderSubmitter.submit(appContext, order)
            _submitting.value = false
            _results.send(result)
        }
    }
}
