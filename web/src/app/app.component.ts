import { ChangeDetectorRef, Component } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { NavigationEnd, Router } from '@angular/router';
import { filter } from 'rxjs';
import { ethers } from 'ethers';
import { BrowserProvider, Eip1193Provider } from 'ethers/types/providers';

declare global {
    interface Window {
        gtag: any;
        ethereum: Eip1193Provider & BrowserProvider;
    }
}

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
})
export class AppComponent {
    ethereum = window.ethereum;
    provider = new ethers.BrowserProvider(window.ethereum);
    signer: ethers.Signer | null = null;
    account: string = '';
    chainName: string = '';

    constructor(router: Router, title: Title, public changeDetector: ChangeDetectorRef) {
        // Google Analytics
        router.events.pipe(filter((e) => e instanceof NavigationEnd)).subscribe((n: any) => {
            title.getTitle();
            window.gtag('config', 'G-F29DBWYW6T', { page_path: n.urlAfterRedirects });
        });

        this.ethereum.on('chainChanged', (chainId: string) => {
            console.log('chain changed to', chainId);
            this.provider = new ethers.BrowserProvider(window.ethereum);
            this.provider.getNetwork().then((network) => { this.chainName = network.name; });
            
            // 0xa869 - Fuji
            
            this.changeDetector.detectChanges();


        });
        this.ethereum.on('accountsChanged', (accounts: string[]) => {
        });

        this.provider.getNetwork().then((network) => {
        });
        this.connect();
    }

    async connect() {
        const result: Promise<string> = this.ethereum.request({ method: 'eth_requestAccounts' });
        console.log('connect result is', result);
        const accountList = await result;
        console.log('and resolves to', accountList);
        this.account = accountList[0];
        this.provider.getNetwork().then((network) => { this.chainName = network.name; });
    }
    async setupSigner() {
        this.signer = await this.provider.getSigner();
    }
}
