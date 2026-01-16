import { useRegisterSW } from 'virtual:pwa-register/react'
import './ReloadPrompt.css'

export function ReloadPrompt() {
    const {
        offlineReady: [offlineReady, setOfflineReady],
        needRefresh: [needRefresh, setNeedRefresh],
        updateServiceWorker,
    } = useRegisterSW({
        onRegistered(r) {
            console.log('SW Registered: ' + r)
        },
        onRegisterError(error) {
            console.log('SW registration error', error)
        },
    })

    const close = () => {
        setOfflineReady(false)
        setNeedRefresh(false)
    }

    return (
        <div className="ReloadPrompt-container">
            {(offlineReady || needRefresh) && (
                <div className="ReloadPrompt-toast">
                    <div className="ReloadPrompt-message">
                        {offlineReady
                            ? 'App ready to work offline'
                            : 'New content available, click on reload button to update.'}
                    </div>
                    {needRefresh && (
                        <button className="ReloadPrompt-toast-button" onClick={() => updateServiceWorker(true)}>
                            Reload
                        </button>
                    )}
                    <button className="ReloadPrompt-toast-button" onClick={() => close()}>
                        Close
                    </button>
                </div>
            )}
        </div>
    )
}
