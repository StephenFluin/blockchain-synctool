import { Component } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { NavigationEnd, Router } from '@angular/router';
import { filter } from 'rxjs';

declare global {
  interface Window {
    gtag: any;
  }
}

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {

  constructor(router: Router, title: Title) {
    router.events
      .pipe(filter((e) => e instanceof NavigationEnd))
      .subscribe((n: any) => {
        title.getTitle();
        window.gtag('config', 'G-F29DBWYW6T', { page_path: n.urlAfterRedirects });
      });
  }
}
