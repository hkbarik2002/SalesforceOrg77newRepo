import { LightningElement } from 'lwc';

export default class Spring26ReleaseLwcTest extends LightningElement {
    message = 'Interact with the box!';
    eventMode = 'click'; // 'click' or 'hover'

    /**
     * THE KEY FEATURE: Returns an object of event handlers
     * The lwc:on directive uses this to attach listeners dynamically
     */
    get boxEventHandlers() {
        const handlers = {};

        switch (this.eventMode) {
            case 'click':
                handlers.click = () => {
                    this.message = '🖱️ You clicked!';
                };
                break;
            case 'hover':
                handlers.mouseenter = () => {
                    this.message = '✨ Mouse entered!';
                };
                handlers.mouseleave = () => {
                    this.message = '👋 Mouse left!';
                };
                break;
            // no default
        }
        console.log('handlers>>>>', handlers);
        return handlers;
    }

    setClickMode() {
        this.eventMode = 'click';
        this.message = 'Now using CLICK mode';
    }

    setHoverMode() {
        this.eventMode = 'hover';
        this.message = 'Now using HOVER mode';
    }

    get clickVariant() {
        return this.eventMode === 'click' ? 'brand' : 'neutral';
    }

    get hoverVariant() {
        return this.eventMode === 'hover' ? 'brand' : 'neutral';
    }

    get boxClass() {
        const modeClass = this.eventMode === 'click' ? 'click-mode' : 'hover-mode';
        return `slds-box slds-box_small slds-text-align_center interactive-box ${modeClass}`;
    }

    get hintText() {
        return this.eventMode === 'click'
            ? '👆 Click here'
            : '🖐️ Hover over me';
    }
}